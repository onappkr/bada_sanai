import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/core/geo/polyline_codec.dart';
import 'package:bada_sanai/core/geo/polyline_simplifier.dart';
import 'package:test/test.dart';

void main() {
  group('PolylineCodec', () {
    test('Google 공식 예제와 일치', () {
      const points = [
        GeoPoint(38.5, -120.2),
        GeoPoint(40.7, -120.95),
        GeoPoint(43.252, -126.453),
      ];
      expect(PolylineCodec.encode(points), '_p~iF~ps|U_ulLnnqC_mqNvxq`@');
      expect(PolylineCodec.decode('_p~iF~ps|U_ulLnnqC_mqNvxq`@'), points);
    });

    test('빈 목록', () {
      expect(PolylineCodec.encode([]), '');
      expect(PolylineCodec.decode(''), isEmpty);
    });

    test('잘린 문자열은 예외', () {
      expect(() => PolylineCodec.decode('_p~iF~ps|'), throwsFormatException);
    });
  });

  group('simplifyPolyline', () {
    test('일직선 위의 중간점 제거', () {
      final pts = [
        const GeoPoint(35.0, 129.0),
        const GeoPoint(35.0, 129.001),
        const GeoPoint(35.0, 129.002),
      ];
      expect(simplifyPolyline(pts, 5), [pts.first, pts.last]);
    });

    test('꺾이는 점은 유지', () {
      final pts = [
        const GeoPoint(35.0, 129.0),
        const GeoPoint(35.001, 129.001),
        const GeoPoint(35.0, 129.002),
      ];
      expect(simplifyPolyline(pts, 5), pts);
    });

    test('점이 2개 이하면 그대로', () {
      const pts = [GeoPoint(35.0, 129.0), GeoPoint(35.1, 129.1)];
      expect(simplifyPolyline(pts, 5), pts);
    });
  });

  test('GeoPoint.distanceTo: 위도 0.01도 ≈ 1.11km', () {
    final d = const GeoPoint(35.0, 129.0).distanceTo(const GeoPoint(35.01, 129.0));
    expect(d, closeTo(1112, 5));
  });
}
