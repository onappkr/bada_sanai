import 'dart:math' as math;

import 'geo_point.dart';

/// 화면 좌표(왼쪽 위가 원점, 아래로 갈수록 y 증가).
typedef ScreenPoint = ({double x, double y});

/// 좌표들을 [width]×[height] 상자 안에 비율을 지키며 맞춰 투영한다.
///
/// 지도 배경 없이 경로와 포인트의 상대 위치만 그릴 때 쓴다. 북쪽이 위쪽이고,
/// 위도가 높을수록 경도 1도가 짧아지는 것을 평균 위도로 보정한다(좁은 지역에서 충분히 정확).
/// 결과는 입력과 같은 순서이고, 모든 점은 [padding] 안쪽에 들어간다.
/// 점이 하나이거나 모두 같은 자리면 상자 중앙에 놓는다.
List<ScreenPoint> projectToBox(
  List<GeoPoint> points, {
  required double width,
  required double height,
  double padding = 16,
}) {
  if (points.isEmpty) return const [];
  assert(width > 2 * padding && height > 2 * padding, '상자가 여백보다 커야 합니다');

  var minLat = points.first.lat, maxLat = points.first.lat;
  var minLng = points.first.lng, maxLng = points.first.lng;
  for (final p in points) {
    minLat = math.min(minLat, p.lat);
    maxLat = math.max(maxLat, p.lat);
    minLng = math.min(minLng, p.lng);
    maxLng = math.max(maxLng, p.lng);
  }

  final cosLat = math.cos((minLat + maxLat) / 2 * math.pi / 180);
  final spanX = (maxLng - minLng) * cosLat; // 경도 차이를 위도 도(度) 단위로 환산
  final spanY = maxLat - minLat;

  final availW = width - 2 * padding;
  final availH = height - 2 * padding;

  // 폭·높이 중 더 빡빡한 쪽에 맞춰 같은 배율을 쓴다. 한 방향 폭이 0이면 다른 쪽만 본다.
  double scale;
  if (spanX == 0 && spanY == 0) {
    scale = 0;
  } else if (spanX == 0) {
    scale = availH / spanY;
  } else if (spanY == 0) {
    scale = availW / spanX;
  } else {
    scale = math.min(availW / spanX, availH / spanY);
  }

  // 남는 공간은 양쪽에 똑같이 나눠 가운데로 모은다.
  final offsetX = padding + (availW - spanX * scale) / 2;
  final offsetY = padding + (availH - spanY * scale) / 2;

  return [
    for (final p in points)
      (
        x: offsetX + (p.lng - minLng) * cosLat * scale,
        y: offsetY + (maxLat - p.lat) * scale,
      ),
  ];
}

/// [points]를 둘러싼 상자를 각 방향으로 [ratio]만큼(범위 크기에 비례) 넓혀 [candidates] 중 그 안에 드는 것만 고른다.
/// 경로 주변 포인트만 같이 그릴 때 쓴다. 경로가 한 점이면 [minSpanDegrees]를 최소 폭으로 본다.
List<T> withinExpandedBounds<T>(
  List<GeoPoint> points,
  Iterable<T> candidates,
  GeoPoint Function(T) locate, {
  double ratio = 0.3,
  double minSpanDegrees = 0.002,
}) {
  if (points.isEmpty) return const [];
  var minLat = points.first.lat, maxLat = points.first.lat;
  var minLng = points.first.lng, maxLng = points.first.lng;
  for (final p in points) {
    minLat = math.min(minLat, p.lat);
    maxLat = math.max(maxLat, p.lat);
    minLng = math.min(minLng, p.lng);
    maxLng = math.max(maxLng, p.lng);
  }
  final padLat = math.max(maxLat - minLat, minSpanDegrees) * ratio;
  final padLng = math.max(maxLng - minLng, minSpanDegrees) * ratio;
  return [
    for (final c in candidates)
      if (locate(c).lat >= minLat - padLat &&
          locate(c).lat <= maxLat + padLat &&
          locate(c).lng >= minLng - padLng &&
          locate(c).lng <= maxLng + padLng)
        c,
  ];
}
