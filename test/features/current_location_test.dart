import 'dart:async';

import 'package:bada_sanai/features/tracking/domain/current_location.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:bada_sanai/features/tracking/domain/tracking_ports.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

LocationSample fix(double lat, {double? acc}) =>
    LocationSample(lat: lat, lng: 129, time: t0, accuracyM: acc);

/// 테스트가 직접 값을 흘려보내는 위치 원천.
class FakeSource implements LocationSource {
  final controller = StreamController<LocationSample>();
  bool cancelled = false;

  FakeSource() {
    controller.onCancel = () => cancelled = true;
  }

  @override
  Stream<LocationSample> watch() => controller.stream;
}

void main() {
  const quick = Duration(milliseconds: 80);

  test('오차가 작은 첫 값을 바로 돌려주고 구독을 끊는다', () async {
    final src = FakeSource();
    final future = currentLocation(src, timeout: const Duration(seconds: 5));
    src.controller.add(fix(35.1, acc: 10));
    expect((await future).lat, 35.1);
    expect(src.cancelled, isTrue);
  });

  test('오차를 모르는 값(null)도 쓸 수 있는 값으로 본다', () async {
    final src = FakeSource();
    final future = currentLocation(src, timeout: const Duration(seconds: 5));
    src.controller.add(fix(35.2));
    expect((await future).lat, 35.2);
  });

  test('처음의 부정확한 값은 건너뛰고 더 정확한 값을 기다린다', () async {
    final src = FakeSource();
    final future = currentLocation(src, timeout: const Duration(seconds: 5));
    src.controller.add(fix(35.0, acc: 300));
    src.controller.add(fix(35.0, acc: 120));
    src.controller.add(fix(35.3, acc: 20));
    expect((await future).lat, 35.3);
  });

  test('시간 안에 정확한 값이 없으면 받은 값 중 가장 정확한 값을 준다', () async {
    final src = FakeSource();
    final future = currentLocation(src, timeout: quick);
    src.controller.add(fix(35.0, acc: 300));
    src.controller.add(fix(35.4, acc: 90));
    src.controller.add(fix(35.0, acc: 200));
    final r = await future;
    expect(r.lat, 35.4);
    expect(src.cancelled, isTrue);
  });

  test('시간 안에 아무 값도 없으면 LocationUnavailable', () async {
    final src = FakeSource();
    await expectLater(
      currentLocation(src, timeout: quick),
      throwsA(isA<LocationUnavailable>()),
    );
    expect(src.cancelled, isTrue);
  });

  test('위치 원천의 오류는 LocationUnavailable로 바뀌어 사용자 문구가 된다', () async {
    final src = FakeSource();
    final future = currentLocation(src, timeout: const Duration(seconds: 5));
    src.controller.addError(StateError('위치 권한이 필요해요'));
    await expectLater(
      future,
      throwsA(isA<LocationUnavailable>()
          .having((e) => e.message, 'message', contains('위치 권한이 필요해요'))),
    );
  });

  test('값 없이 스트림이 끝나면 LocationUnavailable', () async {
    final src = FakeSource();
    final future = currentLocation(src, timeout: const Duration(seconds: 5));
    await src.controller.close();
    await expectLater(future, throwsA(isA<LocationUnavailable>()));
  });

  test('값을 받은 뒤 스트림이 끝나면 그 값을 쓴다', () async {
    final src = FakeSource();
    final future = currentLocation(src, timeout: const Duration(seconds: 5));
    src.controller.add(fix(35.5, acc: 400));
    await src.controller.close();
    expect((await future).lat, 35.5);
  });
}
