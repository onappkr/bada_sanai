import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/core/geo/polyline_codec.dart';
import 'package:bada_sanai/core/geo/polyline_simplifier.dart';
import 'package:bada_sanai/features/tracking/domain/track_visits.dart';
import 'package:bada_sanai/features/tracking/domain/tracking_ports.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

/// 위도 방향으로 [meters] 떨어진 점(위도 1e-5도 ≈ 1.11m).
GeoPoint north(double meters, {double lng = 129.0}) => GeoPoint(35.0 + meters / 111195, lng);

SavedTrack track(String id, List<GeoPoint> line) => SavedTrack(
      id: id,
      startedAt: t0,
      endedAt: t0.add(const Duration(hours: 1)),
      distanceM: 0,
      encodedPolyline: line.isEmpty ? '' : PolylineCodec.encode(line),
    );

void main() {
  group('distanceToPolylineM', () {
    // 서쪽 → 동쪽으로 약 800m 가는 직선(위도 35.0).
    final line = [const GeoPoint(35.0, 129.000), const GeoPoint(35.0, 129.009)];

    test('선 위의 점은 거리 0에 가깝다', () {
      expect(distanceToPolylineM(const GeoPoint(35.0, 129.004), line), closeTo(0, 0.5));
    });

    test('선에서 수직으로 떨어진 거리를 잰다', () {
      // 북쪽으로 50m
      expect(distanceToPolylineM(north(50, lng: 129.004), line), closeTo(50, 1));
    });

    test('끝점 바깥이면 가까운 끝점까지의 거리', () {
      final beyond = GeoPoint(35.0, 129.009 + 100 / (111195 * 0.8192)); // 동쪽 끝에서 약 100m 더
      final d = distanceToPolylineM(beyond, line);
      expect(d, closeTo(100, 3));
    });

    test('꺾은선은 가장 가까운 선분 기준', () {
      final bent = [north(0), north(500), north(500, lng: 129.01)];
      // 두 번째 선분(동쪽으로 가는 선) 위쪽 30m
      expect(distanceToPolylineM(north(530, lng: 129.005), bent), closeTo(30, 1));
    });

    test('빈 선은 무한대, 한 점은 그 점까지의 거리', () {
      expect(distanceToPolylineM(const GeoPoint(35, 129), const []), double.infinity);
      expect(distanceToPolylineM(north(80), [north(0)]), closeTo(80, 1));
    });
  });

  group('tracksNearPoint', () {
    final spot = north(300); // 경로의 중간쯤에 있는 포인트

    test('100m 이내를 지난 경로만 입력 순서대로 고른다', () {
      final passes = track('passes', [north(0), north(600)]); // 포인트 위를 지남
      final near = track('near', [north(0, lng: 129.0006), north(600, lng: 129.0006)]); // 약 55m 옆
      final far = track('far', [north(0, lng: 129.01), north(600, lng: 129.01)]); // 800m+ 옆
      final r = tracksNearPoint([far, near, passes], spot);
      expect(r.map((e) => e.id), ['near', 'passes']);
    });

    test('거리 기준은 바꿀 수 있다', () {
      final side = track('side', [north(0, lng: 129.0006), north(600, lng: 129.0006)]);
      expect(tracksNearPoint([side], spot, radiusM: 30), isEmpty);
      expect(tracksNearPoint([side], spot, radiusM: 80).length, 1);
    });

    test('점이 없는 경로는 어디도 지나지 않은 것으로 본다', () {
      expect(tracksNearPoint([track('empty', const [])], spot), isEmpty);
    });

    test('경로가 한 점이어도 가까우면 방문', () {
      expect(tracksNearPoint([track('dot', [north(310)])], spot).length, 1);
      expect(tracksNearPoint([track('dot', [north(900)])], spot), isEmpty);
    });

    test('경로가 없으면 빈 목록', () {
      expect(tracksNearPoint(const [], spot), isEmpty);
    });
  });
}
