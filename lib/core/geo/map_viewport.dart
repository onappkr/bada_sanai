import 'geo_point.dart';

/// 지도를 처음 열 때 어디를 보여 줄지에 대한 계획. 지도 라이브러리와 무관한 순수 값이다.
///
/// [bounds]가 있으면 그 범위가 모두 보이게 맞추고, 없으면 [center]와 [zoom]으로 연다.
class MapViewportPlan {
  const MapViewportPlan.center(GeoPoint this.center, double this.zoom) : bounds = null;

  const MapViewportPlan.fit(GeoBounds this.bounds)
      : center = null,
        zoom = null;

  final GeoPoint? center;
  final double? zoom;
  final GeoBounds? bounds;
}

/// 남서쪽·북동쪽 모서리로 정한 직사각형 범위.
class GeoBounds {
  const GeoBounds({required this.south, required this.west, required this.north, required this.east});

  final double south;
  final double west;
  final double north;
  final double east;

  GeoPoint get southWest => GeoPoint(south, west);
  GeoPoint get northEast => GeoPoint(north, east);
}

/// 데이터가 없을 때 보여 줄 기본 위치(한반도 전체가 보이는 정도).
const koreaOverview = MapViewportPlan.center(GeoPoint(36.5, 127.8), 6.5);

/// 이 값(도)보다 범위가 작으면 한 곳으로 본다. 위도 1e-4도는 약 11m다.
const _singleSpotSpanDegrees = 1e-4;

/// [points]를 모두 보여 주는 첫 화면 계획.
/// 점이 없으면 한반도 전체, 한 곳(또는 모두 거의 같은 자리)이면 그곳을 [singleSpotZoom]으로,
/// 그 밖에는 모든 점이 들어오는 범위로 맞춘다.
MapViewportPlan planViewport(List<GeoPoint> points, {double singleSpotZoom = 15}) {
  if (points.isEmpty) return koreaOverview;

  var south = points.first.lat, north = points.first.lat;
  var west = points.first.lng, east = points.first.lng;
  for (final p in points) {
    if (p.lat < south) south = p.lat;
    if (p.lat > north) north = p.lat;
    if (p.lng < west) west = p.lng;
    if (p.lng > east) east = p.lng;
  }

  if (north - south < _singleSpotSpanDegrees && east - west < _singleSpotSpanDegrees) {
    return MapViewportPlan.center(
      GeoPoint((north + south) / 2, (east + west) / 2),
      singleSpotZoom,
    );
  }
  return MapViewportPlan.fit(GeoBounds(south: south, west: west, north: north, east: east));
}
