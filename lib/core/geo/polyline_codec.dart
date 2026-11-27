import 'geo_point.dart';

/// Google Encoded Polyline 알고리즘(정밀도 1e5, 약 1m).
/// 이동 경로를 짧은 문자열로 저장·공유하기 위해 사용한다.
class PolylineCodec {
  const PolylineCodec._();

  static String encode(List<GeoPoint> points) {
    final sb = StringBuffer();
    var prevLat = 0, prevLng = 0;
    for (final p in points) {
      final lat = (p.lat * 1e5).round();
      final lng = (p.lng * 1e5).round();
      _write(sb, lat - prevLat);
      _write(sb, lng - prevLng);
      prevLat = lat;
      prevLng = lng;
    }
    return sb.toString();
  }

  static List<GeoPoint> decode(String encoded) {
    final result = <GeoPoint>[];
    var index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      for (var k = 0; k < 2; k++) {
        var shift = 0, value = 0, b = 0;
        do {
          if (index >= encoded.length) {
            throw const FormatException('잘린 polyline 문자열');
          }
          b = encoded.codeUnitAt(index++) - 63;
          value |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        final delta = (value & 1) != 0 ? ~(value >> 1) : (value >> 1);
        if (k == 0) {
          lat += delta;
        } else {
          lng += delta;
        }
      }
      result.add(GeoPoint(lat / 1e5, lng / 1e5));
    }
    return result;
  }

  static void _write(StringBuffer sb, int value) {
    var v = value < 0 ? ~(value << 1) : (value << 1);
    while (v >= 0x20) {
      sb.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }
    sb.writeCharCode(v + 63);
  }
}
