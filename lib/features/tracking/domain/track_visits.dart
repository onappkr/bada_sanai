import '../../../core/geo/geo_point.dart';
import '../../../core/geo/polyline_codec.dart';
import '../../../core/geo/polyline_simplifier.dart';
import 'tracking_ports.dart';

/// 포인트에서 이 거리(미터) 안을 지난 경로를 "방문"으로 본다.
const visitRadiusM = 100.0;

/// [point] 근처([radiusM] 이내)를 지난 경로만 골라 입력 순서 그대로 돌려준다.
///
/// 경로는 5m 오차로 단순화돼 저장되므로 꺾은선까지의 최단 거리로 판단한다.
/// 점이 없는 경로(빈 문자열)는 어디도 지나지 않은 것으로 본다.
List<SavedTrack> tracksNearPoint(
  Iterable<SavedTrack> tracks,
  GeoPoint point, {
  double radiusM = visitRadiusM,
}) {
  return [
    for (final t in tracks)
      if (t.encodedPolyline.isNotEmpty &&
          distanceToPolylineM(point, PolylineCodec.decode(t.encodedPolyline)) <= radiusM)
        t,
  ];
}
