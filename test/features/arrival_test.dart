import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/features/arrival/domain/arrival_detector.dart';
import 'package:bada_sanai/features/arrival/domain/coast_cells.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

/// 위도 방향으로 [meters] 떨어진 점(위도 1e-5도 ≈ 1.11m).
GeoPoint north(double meters, {double lat0 = 35.0, double lng = 129.0}) =>
    GeoPoint(lat0 + meters / 111195, lng);

LocationSample at(Duration after, GeoPoint p, {double? acc}) => LocationSample(
      lat: p.lat,
      lng: p.lng,
      time: t0.add(after),
      accuracyM: acc,
    );

Duration min(num m) => Duration(seconds: (m * 60).round());

void main() {
  group('CoastCells 읽기', () {
    test('정상 파일을 읽는다', () {
      final c = CoastCells.parse('{"version":2,"cell_radius_m":120,"cells":[[34.88,128.62],[34.881,128.622]]}');
      expect(c.version, 2);
      expect(c.cellRadiusM, 120);
      expect(c.cells.length, 2);
      expect(c.cells.first, const GeoPoint(34.88, 128.62));
      expect(c.isUsable, isTrue);
    });

    test('반경을 생략하면 100m, 셀이 없으면 쓸 수 없다', () {
      final c = CoastCells.parse('{"version":0,"cells":[]}');
      expect(c.cellRadiusM, CoastCells.defaultCellRadiusM);
      expect(c.isUsable, isFalse);
      expect(CoastCells.empty.isUsable, isFalse);
    });

    group('형식 오류는 FormatException', () {
      void bad(String why, String json) =>
          test(why, () => expect(() => CoastCells.parse(json), throwsFormatException));

      bad('JSON이 아님', '안녕');
      bad('최상위가 객체가 아님', '[]');
      bad('반경이 0', '{"cell_radius_m":0,"cells":[]}');
      bad('셀이 두 값이 아님', '{"cells":[[1.0]]}');
      bad('위도 범위 초과', '{"cells":[[91.0,129.0]]}');
      bad('경도 범위 초과', '{"cells":[[35.0,181.0]]}');
      bad('숫자가 아닌 좌표', '{"cells":[["a","b"]]}');
    });
  });

  group('CoastCells 선택', () {
    final cells = CoastCells(cells: [north(0), north(300), north(100), north(5000)]);

    test('가까운 순으로 N개를 고른다', () {
      final r = cells.nearest(north(90), 3);
      expect(r, [north(100), north(0), north(300)]);
    });

    test('셀이 N개보다 적으면 있는 만큼, 0 이하면 빈 목록', () {
      expect(cells.nearest(north(0), 10).length, 4);
      expect(cells.nearest(north(0), 0), isEmpty);
      expect(const CoastCells().nearest(north(0), 5), isEmpty);
    });

    test('반경 안의 가장 가까운 셀을 찾고, 밖이면 null', () {
      expect(cells.cellContaining(north(95)), north(100));
      expect(cells.cellContaining(north(1000)), isNull);
    });
  });

  group('ArrivalDetector', () {
    final cells = CoastCells(cells: [north(0)]); // 반경 100m
    late ArrivalDetector d;
    setUp(() => d = ArrivalDetector(cells));

    test('셀 안에 3분 머물면 도착 이벤트가 한 번 난다', () {
      expect(d.onSample(at(Duration.zero, north(10))), isNull);
      expect(d.isInside, isTrue);
      expect(d.onSample(at(min(2), north(20))), isNull);
      final e = d.onSample(at(min(3), north(15)));
      expect(e, isNotNull);
      expect(e!.at, t0.add(min(3)));
      expect(e.cell, north(0));
    });

    test('같은 체류에서는 다시 알리지 않는다', () {
      d.onSample(at(Duration.zero, north(10)));
      expect(d.onSample(at(min(3), north(10))), isNotNull);
      expect(d.onSample(at(min(4), north(10))), isNull);
      expect(d.onSample(at(min(10), north(10))), isNull);
    });

    test('3분이 안 되어 나가면 이벤트 없음, 다시 들어오면 시간을 새로 잰다', () {
      d.onSample(at(Duration.zero, north(10)));
      d.onSample(at(min(2), north(10)));
      d.onSample(at(min(2.5), north(500))); // 멀리 나감
      expect(d.isInside, isFalse);
      expect(d.onSample(at(min(3), north(10))), isNull); // 새 체류 시작
      expect(d.onSample(at(min(5), north(10))), isNull); // 2분
      expect(d.onSample(at(min(6), north(10))), isNotNull); // 3분
    });

    test('셀 밖에서 지나가기만 하면 이벤트 없음', () {
      for (var i = 0; i < 20; i++) {
        expect(d.onSample(at(min(i), north(300))), isNull);
      }
    });

    test('경계에서 흔들려도(반경~1.5배 사이) 머문 시간이 끊기지 않는다', () {
      d.onSample(at(Duration.zero, north(50)));
      d.onSample(at(min(1), north(130))); // 반경 밖이지만 1.5배(150m) 안
      expect(d.isInside, isTrue);
      expect(d.onSample(at(min(3), north(60))), isNotNull);
    });

    test('1.5배(150m)를 넘게 나가면 체류가 끝난다', () {
      d.onSample(at(Duration.zero, north(50)));
      d.onSample(at(min(1), north(200)));
      expect(d.isInside, isFalse);
    });

    test('오차가 큰 측정값은 무시한다(체류도 끊지 않는다)', () {
      d.onSample(at(Duration.zero, north(10)));
      expect(d.onSample(at(min(1), north(900), acc: 200)), isNull); // 튄 값
      expect(d.isInside, isTrue);
      expect(d.onSample(at(min(3), north(10))), isNotNull);
    });

    test('같은 구역은 6시간 안에 다시 알리지 않고, 지나면 다시 알린다', () {
      d.onSample(at(Duration.zero, north(10)));
      expect(d.onSample(at(min(3), north(10))), isNotNull);
      d.onSample(at(min(10), north(600))); // 떠남

      // 1시간 뒤 같은 곳에 다시 도착: 제한에 걸린다.
      d.onSample(at(const Duration(hours: 1), north(10)));
      expect(d.onSample(at(const Duration(hours: 1, minutes: 3), north(10))), isNull);
      d.onSample(at(const Duration(hours: 1, minutes: 20), north(600)));

      // 7시간 뒤: 다시 알린다.
      d.onSample(at(const Duration(hours: 7), north(10)));
      expect(d.onSample(at(const Duration(hours: 7, minutes: 3), north(10))), isNotNull);
    });

    test('다른 구역(1km 이상 떨어진 해안)은 따로 센다', () {
      final far = CoastCells(cells: [north(0), north(3000)]);
      final det = ArrivalDetector(far);
      det.onSample(at(Duration.zero, north(0)));
      expect(det.onSample(at(min(3), north(0))), isNotNull);
      det.onSample(at(min(10), north(1500))); // 두 셀 어디서도 멀다
      det.onSample(at(min(20), north(3000)));
      final e = det.onSample(at(min(23), north(3000)));
      expect(e, isNotNull); // 6시간이 안 지났어도 다른 구역이라 알린다
      expect(e!.zone, isNot(ArrivalDetector.zoneOf(north(0))));
    });

    test('가까운 셀을 따라 걸어도 같은 구역이라 반복해서 알리지 않는다', () {
      final line = CoastCells(cells: [for (var i = 0; i < 6; i++) north(i * 150.0)]);
      final det = ArrivalDetector(line);
      det.onSample(at(Duration.zero, north(0)));
      expect(det.onSample(at(min(3), north(0))), isNotNull);
      // 해안을 따라 700m 걸어가며 계속 셀 안에 있다가 3분 넘게 머문다.
      for (var i = 1; i <= 5; i++) {
        det.onSample(at(min(3 + i), north(i * 150.0)));
      }
      expect(det.onSample(at(min(20), north(750))), isNull);
    });

    test('측정이 오래 끊겼다가 같은 셀에서 이어지면 머문 시간을 새로 잰다', () {
      d.onSample(at(Duration.zero, north(10)));
      // 앱이 꺼져 있다가 2시간 뒤 첫 측정: 공백을 머문 시간으로 세면 안 된다.
      expect(d.onSample(at(const Duration(hours: 2), north(10))), isNull);
      expect(d.onSample(at(const Duration(hours: 2, minutes: 2), north(10))), isNull);
      expect(d.onSample(at(const Duration(hours: 2, minutes: 3), north(10))), isNotNull);
    });

    test('reset하면 상태와 재알림 기록이 모두 지워진다', () {
      d.onSample(at(Duration.zero, north(10)));
      expect(d.onSample(at(min(3), north(10))), isNotNull);
      d.reset();
      expect(d.isInside, isFalse);
      d.onSample(at(min(10), north(10)));
      expect(d.onSample(at(min(13), north(10))), isNotNull); // 6시간 제한도 사라짐
    });

    test('셀이 없으면 아무것도 감지하지 않는다', () {
      final none = ArrivalDetector(CoastCells.empty);
      for (var i = 0; i < 10; i++) {
        expect(none.onSample(at(min(i), north(0))), isNull);
      }
    });
  });
}
