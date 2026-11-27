import 'dart:async';

import 'track_logic.dart';
import 'tracking_ports.dart';

/// 현재 위치를 얻지 못했을 때. [message]는 사용자에게 그대로 보여 줄 수 있다.
class LocationUnavailable implements Exception {
  const LocationUnavailable(this.message);

  final String message;

  @override
  String toString() => message;
}

/// [source]에서 쓸 만한 첫 위치를 기다려 돌려준다.
///
/// 오차가 [maxAccuracyM]보다 큰 값은 건너뛰고 더 정확한 값을 기다린다(GPS가 막 켜지면
/// 처음 값이 수백 m씩 틀리는 일이 흔하다). [timeout] 안에 쓸 만한 값이 없으면
/// 마지막으로 받은 값 중 가장 정확한 것을 주되, 그마저 없으면 [LocationUnavailable]을 던진다.
/// 위치 원천의 오류(권한 없음 등)는 [LocationUnavailable]로 바꿔 던진다.
Future<LocationSample> currentLocation(
  LocationSource source, {
  Duration timeout = const Duration(seconds: 20),
  double maxAccuracyM = TrackConfig.maxAccuracyM,
}) async {
  LocationSample? best;
  final done = Completer<LocationSample>();
  late final StreamSubscription<LocationSample> sub;

  void finish() {
    if (done.isCompleted) return;
    if (best != null) {
      done.complete(best);
    } else {
      done.completeError(const LocationUnavailable('현재 위치를 찾지 못했어요. 잠시 뒤 다시 시도해 주세요.'));
    }
  }

  sub = source.watch().listen(
    (s) {
      final acc = s.accuracyM;
      // 지금까지 중 가장 정확한 값을 기억해 둔다(시간 초과 시 대신 쓴다).
      if (best == null || (acc ?? 0) < (best!.accuracyM ?? 0)) best = s;
      if (acc == null || acc <= maxAccuracyM) {
        if (!done.isCompleted) done.complete(s);
      }
    },
    onError: (Object e) {
      if (!done.isCompleted) done.completeError(LocationUnavailable('$e'));
    },
    onDone: finish,
  );

  final timer = Timer(timeout, finish);
  try {
    return await done.future;
  } finally {
    timer.cancel();
    await sub.cancel();
  }
}
