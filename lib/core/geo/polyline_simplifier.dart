import 'dart:math' as math;

import 'geo_point.dart';

/// Douglas-Peucker 경로 단순화. [toleranceMeters] 이내로 벗어난 점은 제거한다.
/// 시작점과 끝점은 항상 유지된다.
List<GeoPoint> simplifyPolyline(List<GeoPoint> points, double toleranceMeters) {
  if (points.length < 3) return List.of(points);
  final keep = List<bool>.filled(points.length, false);
  keep[0] = true;
  keep[points.length - 1] = true;

  final stack = <(int, int)>[(0, points.length - 1)];
  while (stack.isNotEmpty) {
    final (start, end) = stack.removeLast();
    var maxDist = 0.0;
    var index = -1;
    for (var i = start + 1; i < end; i++) {
      final d = _crossTrackMeters(points[i], points[start], points[end]);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }
    if (index != -1 && maxDist > toleranceMeters) {
      keep[index] = true;
      stack.add((start, index));
      stack.add((index, end));
    }
  }
  return [
    for (var i = 0; i < points.length; i++)
      if (keep[i]) points[i],
  ];
}

/// 선분 a-b로부터 p까지의 거리(미터). 국소 평면 근사(equirectangular).
double _crossTrackMeters(GeoPoint p, GeoPoint a, GeoPoint b) {
  const r = 6371000.0;
  final latRef = a.lat * math.pi / 180;
  double x(GeoPoint g) => (g.lng - a.lng) * math.pi / 180 * math.cos(latRef) * r;
  double y(GeoPoint g) => (g.lat - a.lat) * math.pi / 180 * r;

  final bx = x(b), by = y(b);
  final px = x(p), py = y(p);
  final len2 = bx * bx + by * by;
  if (len2 == 0) return math.sqrt(px * px + py * py);
  final t = ((px * bx + py * by) / len2).clamp(0.0, 1.0);
  final dx = px - t * bx, dy = py - t * by;
  return math.sqrt(dx * dx + dy * dy);
}
