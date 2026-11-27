import 'dart:math' as math;

import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/core/geo/projection.dart';
import 'package:test/test.dart';

void main() {
  group('projectToBox', () {
    test('점이 없으면 빈 목록', () {
      expect(projectToBox(const [], width: 100, height: 100), isEmpty);
    });

    test('점이 하나면 상자 중앙', () {
      final r = projectToBox([const GeoPoint(35, 129)], width: 200, height: 100);
      expect(r.single.x, closeTo(100, 1e-9));
      expect(r.single.y, closeTo(50, 1e-9));
    });

    test('북쪽이 위쪽이다(위도가 높을수록 y가 작다)', () {
      final r = projectToBox(
        [const GeoPoint(35.00, 129.0), const GeoPoint(35.01, 129.0)],
        width: 100,
        height: 200,
      );
      expect(r[1].y, lessThan(r[0].y));
    });

    test('동쪽이 오른쪽이다(경도가 클수록 x가 크다)', () {
      final r = projectToBox(
        [const GeoPoint(35, 129.00), const GeoPoint(35, 129.01)],
        width: 200,
        height: 100,
      );
      expect(r[1].x, greaterThan(r[0].x));
    });

    test('모든 점이 여백 안쪽에 들어간다', () {
      final pts = [
        for (var i = 0; i < 50; i++)
          GeoPoint(35 + math.sin(i) * 0.01, 129 + math.cos(i * 1.3) * 0.02),
      ];
      const pad = 12.0;
      final r = projectToBox(pts, width: 300, height: 180, padding: pad);
      for (final p in r) {
        expect(p.x, inInclusiveRange(pad - 1e-9, 300 - pad + 1e-9));
        expect(p.y, inInclusiveRange(pad - 1e-9, 180 - pad + 1e-9));
      }
    });

    test('가로로 긴 경로는 좌우 끝이 여백에 닿고 위아래는 가운데로 모인다', () {
      final r = projectToBox(
        [const GeoPoint(35.000, 129.0), const GeoPoint(35.000, 129.05)],
        width: 300,
        height: 300,
        padding: 10,
      );
      expect(r.first.x, closeTo(10, 1e-9));
      expect(r.last.x, closeTo(290, 1e-9));
      expect(r.first.y, closeTo(150, 1e-9)); // 세로 폭 0 → 가운데
    });

    test('배율이 가로세로 같아 비율이 유지된다(위도 보정 포함)', () {
      // 위도 60도에서는 경도 1도 ≈ 위도 0.5도 길이.
      final r = projectToBox(
        [const GeoPoint(60, 10), const GeoPoint(61, 11)],
        width: 400,
        height: 400,
        padding: 0,
      );
      final dx = (r[1].x - r[0].x).abs();
      final dy = (r[1].y - r[0].y).abs();
      final cos = math.cos(60.5 * math.pi / 180);
      expect(dx / dy, closeTo(cos, 1e-9)); // 경도 1도 : 위도 1도 = cos : 1
    });

    test('같은 자리의 점 여러 개도 문제없이 중앙에 모인다', () {
      final r = projectToBox(
        [const GeoPoint(35, 129), const GeoPoint(35, 129)],
        width: 100,
        height: 100,
      );
      expect(r.every((p) => p.x == 50 && p.y == 50), isTrue);
    });

    test('결과는 입력과 같은 순서·개수', () {
      final pts = [for (var i = 0; i < 7; i++) GeoPoint(35 + i * 0.001, 129)];
      expect(projectToBox(pts, width: 100, height: 300).length, 7);
    });
  });

  group('withinExpandedBounds', () {
    const route = [GeoPoint(35.000, 129.000), GeoPoint(35.010, 129.010)];
    GeoPoint at(double lat, double lng) => GeoPoint(lat, lng);

    test('경로 상자 + 30% 안의 후보만 고른다', () {
      final inside = at(35.005, 129.005);
      final nearEdge = at(35.012, 129.012); // 상자 밖이지만 30%(0.003) 이내
      final far = at(35.020, 129.020);
      final r = withinExpandedBounds<GeoPoint>(route, [inside, nearEdge, far], (p) => p);
      expect(r, [inside, nearEdge]);
    });

    test('경로가 한 점이어도 최소 폭 안의 후보는 고른다', () {
      final r = withinExpandedBounds<GeoPoint>(
        [at(35, 129)],
        [at(35.0004, 129.0004), at(35.01, 129.01)],
        (p) => p,
      );
      expect(r.length, 1);
    });

    test('경로가 비면 아무것도 고르지 않는다', () {
      expect(withinExpandedBounds<GeoPoint>(const [], [at(1, 1)], (p) => p), isEmpty);
    });
  });
}
