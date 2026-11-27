import 'dart:async';

import '../../tracking/domain/track_logic.dart';
import '../../tracking/domain/tracking_ports.dart';
import 'arrival_detector.dart';
import 'coast_cells.dart';

enum ArrivalWatchPhase {
  /// 감시하지 않는 중.
  stopped,

  /// 위치를 받으며 도착을 기다리는 중.
  watching,

  /// 해안 셀 데이터가 비어 있어 감지할 수 없다.
  noData,

  /// 위치를 받지 못하는 문제(권한 없음, 위치 꺼짐 등).
  error,
}

class ArrivalWatchState {
  const ArrivalWatchState(this.phase, {this.message});

  final ArrivalWatchPhase phase;

  /// [ArrivalWatchPhase.error]일 때 사용자에게 보여 줄 문장.
  final String? message;

  static const stopped = ArrivalWatchState(ArrivalWatchPhase.stopped);
}

/// 위치를 계속 받아 [ArrivalDetector]에 넣고, 도착하면 [onArrival]을 부른다.
/// 프레임워크에 묶이지 않아 시험할 수 있다(실제 알림·권한은 바깥에서 연결한다).
class ArrivalWatcher {
  ArrivalWatcher({
    required this.source,
    required this.cells,
    required this.onArrival,
    this.onChanged,
    ArrivalDetector? detector,
  }) : _detector = detector ?? ArrivalDetector(cells);

  final LocationSource source;
  final CoastCells cells;
  final void Function(ArrivalEvent) onArrival;
  final void Function(ArrivalWatchState)? onChanged;
  final ArrivalDetector _detector;

  ArrivalWatchState _state = ArrivalWatchState.stopped;
  StreamSubscription<LocationSample>? _sub;

  ArrivalWatchState get state => _state;

  void _emit(ArrivalWatchState s) {
    _state = s;
    onChanged?.call(s);
  }

  /// 감시를 시작한다. 이미 감시 중이면 아무것도 하지 않는다.
  /// 해안 셀이 없으면 위치를 켜지 않고 [ArrivalWatchPhase.noData]로 둔다(배터리를 쓰지 않는다).
  Future<void> start() async {
    if (_sub != null) return;
    if (!cells.isUsable) {
      _emit(const ArrivalWatchState(ArrivalWatchPhase.noData));
      return;
    }
    _emit(const ArrivalWatchState(ArrivalWatchPhase.watching));
    _sub = source.watch().listen(
      _onSample,
      onError: (Object e) async {
        // 위치를 받을 수 없으면 더 기다려도 소용없으니 감시를 멈추고 이유를 알린다.
        await _sub?.cancel();
        _sub = null;
        _emit(ArrivalWatchState(ArrivalWatchPhase.error, message: '$e'));
      },
      onDone: () {
        _sub = null;
        if (_state.phase == ArrivalWatchPhase.watching) _emit(ArrivalWatchState.stopped);
      },
    );
  }

  void _onSample(LocationSample s) {
    final event = _detector.onSample(s);
    if (event != null) onArrival(event);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _emit(ArrivalWatchState.stopped);
  }
}

/// 도착 알림의 제목과 본문.
({String title, String body}) arrivalNotificationText() => (
      title: '바다에 도착하셨네요',
      body: '이동 경로를 저장할까요? 눌러서 기록을 시작하세요.',
    );

/// 알림을 눌렀을 때 앱이 받는 값(어느 화면으로 갈지 정한다).
const arrivalNotificationPayload = 'arrival';
