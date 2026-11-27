import 'dart:async';

import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/features/arrival/domain/arrival_detector.dart';
import 'package:bada_sanai/features/arrival/domain/arrival_watcher.dart';
import 'package:bada_sanai/features/arrival/domain/coast_cells.dart';
import 'package:bada_sanai/features/share/domain/deep_link.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:bada_sanai/features/tracking/domain/tracking_ports.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

GeoPoint north(double meters) => GeoPoint(35.0 + meters / 111195, 129.0);

LocationSample at(Duration after, GeoPoint p) =>
    LocationSample(lat: p.lat, lng: p.lng, time: t0.add(after), accuracyM: 8);

class FakeSource implements LocationSource {
  final controller = StreamController<LocationSample>.broadcast();
  int subscribes = 0;

  @override
  Stream<LocationSample> watch() {
    subscribes++;
    return controller.stream;
  }
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeSource source;
  late List<ArrivalEvent> arrivals;
  late List<ArrivalWatchState> states;
  final coast = CoastCells(cells: [north(0)]);

  ArrivalWatcher make({CoastCells? cells}) => ArrivalWatcher(
        source: source,
        cells: cells ?? coast,
        onArrival: arrivals.add,
        onChanged: states.add,
      );

  setUp(() {
    source = FakeSource();
    arrivals = [];
    states = [];
  });

  group('ArrivalWatcher', () {
    test('해안에 3분 머물면 도착을 알린다', () async {
      final w = make();
      await w.start();
      expect(w.state.phase, ArrivalWatchPhase.watching);

      source.controller.add(at(Duration.zero, north(10)));
      source.controller.add(at(const Duration(minutes: 3), north(10)));
      await pump();

      expect(arrivals.length, 1);
      expect(arrivals.single.cell, north(0));
      await w.stop();
    });

    test('해안을 지나가기만 하면 알리지 않는다', () async {
      final w = make();
      await w.start();
      for (var i = 0; i < 6; i++) {
        source.controller.add(at(Duration(minutes: i), north(500)));
      }
      await pump();
      expect(arrivals, isEmpty);
      await w.stop();
    });

    test('같은 체류에서는 한 번만 알린다', () async {
      final w = make();
      await w.start();
      for (var m = 0; m <= 10; m++) {
        source.controller.add(at(Duration(minutes: m), north(10)));
      }
      await pump();
      expect(arrivals.length, 1);
      await w.stop();
    });

    test('해안 셀이 없으면 위치를 켜지 않고 noData 상태가 된다', () async {
      final w = make(cells: CoastCells.empty);
      await w.start();
      expect(w.state.phase, ArrivalWatchPhase.noData);
      expect(source.subscribes, 0); // 배터리를 쓰지 않는다
    });

    test('이미 감시 중이면 start를 다시 불러도 한 번만 구독한다', () async {
      final w = make();
      await w.start();
      await w.start();
      expect(source.subscribes, 1);
      await w.stop();
    });

    test('멈추면 이후 위치는 무시한다', () async {
      final w = make();
      await w.start();
      await w.stop();
      expect(w.state.phase, ArrivalWatchPhase.stopped);
      source.controller.add(at(Duration.zero, north(10)));
      source.controller.add(at(const Duration(minutes: 5), north(10)));
      await pump();
      expect(arrivals, isEmpty);
    });

    test('위치 오류(권한 없음)가 나면 감시를 멈추고 이유를 알린다', () async {
      final w = make();
      await w.start();
      source.controller.addError(StateError('위치 권한이 필요해요'));
      await pump();
      expect(w.state.phase, ArrivalWatchPhase.error);
      expect(w.state.message, contains('위치 권한이 필요해요'));
    });

    test('오류 뒤에 다시 시작할 수 있다', () async {
      final w = make();
      await w.start();
      source.controller.addError(StateError('꺼짐'));
      await pump();
      await w.start();
      expect(w.state.phase, ArrivalWatchPhase.watching);
      expect(source.subscribes, 2);
      await w.stop();
    });

    test('상태 변화를 순서대로 알린다', () async {
      final w = make();
      await w.start();
      await w.stop();
      expect(states.map((s) => s.phase), [ArrivalWatchPhase.watching, ArrivalWatchPhase.stopped]);
    });
  });

  test('알림 문구에 제목과 본문이 있다', () {
    final t = arrivalNotificationText();
    expect(t.title, isNotEmpty);
    expect(t.body, contains('경로'));
    expect(arrivalNotificationPayload, 'arrival');
  });

  group('sharedPointFragment (앱 링크 해석)', () {
    test('# 뒤의 조각을 읽는다', () {
      final f = sharedPointFragment(Uri.parse('https://bada.test/p#v=1&d=abc-_123'));
      expect(f, 'v=1&d=abc-_123');
    });

    test('조각이 안 넘어오면 쿼리를 대신 읽는다', () {
      final f = sharedPointFragment(Uri.parse('https://bada.test/p?v=1&d=abc'));
      expect(f, 'v=1&d=abc');
    });

    test('조각과 쿼리가 모두 있으면 조각이 우선', () {
      final f = sharedPointFragment(Uri.parse('https://bada.test/p?d=query#v=1&d=fragment'));
      expect(f, 'v=1&d=fragment');
    });

    test('버전이 없으면 1로 본다', () {
      expect(sharedPointFragment(Uri.parse('https://bada.test/p#d=abc')), 'v=1&d=abc');
    });

    test('경로가 /p가 아니거나 데이터가 없으면 null', () {
      expect(sharedPointFragment(Uri.parse('https://bada.test/other#v=1&d=abc')), isNull);
      expect(sharedPointFragment(Uri.parse('https://bada.test/p')), isNull);
      expect(sharedPointFragment(Uri.parse('https://bada.test/p#v=1&d=')), isNull);
      expect(sharedPointFragment(Uri.parse('https://bada.test/p#hello')), isNull);
    });

    test('http(s)가 아닌 주소는 받지 않는다', () {
      expect(sharedPointFragment(Uri.parse('badasanai://p#v=1&d=abc')), isNull);
      expect(sharedPointFragment(Uri.parse('javascript:alert(1)')), isNull);
    });

    test('허용한 도메인만 받는다', () {
      final uri = Uri.parse('https://evil.test/p#v=1&d=abc');
      expect(sharedPointFragment(uri, allowedHosts: {'bada.test'}), isNull);
      expect(sharedPointFragment(Uri.parse('https://bada.test/p#v=1&d=abc'), allowedHosts: {'bada.test'}), isNotNull);
    });
  });
}
