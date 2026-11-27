import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/core/geo/map_viewport.dart';
import 'package:test/test.dart';

void main() {
  test('점이 없으면 한반도 전체', () {
    final p = planViewport(const []);
    expect(p.bounds, isNull);
    expect(p.center!.lat, closeTo(36.5, 1e-9));
    expect(p.zoom, lessThan(8));
  });

  test('점이 하나면 그 점을 확대해서 연다', () {
    final p = planViewport(const [GeoPoint(35.0779, 129.0868)]);
    expect(p.bounds, isNull);
    expect(p.center, const GeoPoint(35.0779, 129.0868));
    expect(p.zoom, 15);
  });

  test('모두 거의 같은 자리(11m 안)여도 한 곳으로 본다', () {
    final p = planViewport(const [GeoPoint(35.0, 129.0), GeoPoint(35.00005, 129.00005)]);
    expect(p.bounds, isNull);
    expect(p.center!.lat, closeTo(35.000025, 1e-9));
  });

  test('확대 정도는 바꿀 수 있다', () {
    expect(planViewport(const [GeoPoint(35, 129)], singleSpotZoom: 12).zoom, 12);
  });

  test('여러 점이면 모두 들어오는 범위(남서·북동)로 맞춘다', () {
    final p = planViewport(const [
      GeoPoint(35.10, 129.00),
      GeoPoint(35.00, 129.20),
      GeoPoint(35.05, 128.90),
    ]);
    expect(p.center, isNull);
    final b = p.bounds!;
    expect((b.south, b.north), (35.00, 35.10));
    expect((b.west, b.east), (128.90, 129.20));
    expect(b.southWest, const GeoPoint(35.00, 128.90));
    expect(b.northEast, const GeoPoint(35.10, 129.20));
  });

  test('한쪽 방향으로만 퍼진 점들도 범위로 본다(폭 0인 방향이 있어도)', () {
    final p = planViewport(const [GeoPoint(35.0, 129.0), GeoPoint(35.05, 129.0)]);
    expect(p.bounds, isNotNull);
    expect(p.bounds!.west, p.bounds!.east);
  });
}
