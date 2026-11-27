import '../../../core/geo/geo_point.dart';
import '../../../core/geo/polyline_codec.dart';
import '../../../core/geo/polyline_simplifier.dart';

/// 위치 한 번의 측정값.
class LocationSample {
  const LocationSample({
    required this.lat,
    required this.lng,
    required this.time,
    this.accuracyM,
    this.speedMps,
  });

  final double lat;
  final double lng;
  final DateTime time;

  /// 위치 오차 반경(미터). 모르면 null.
  final double? accuracyM;

  /// 이동 속도(m/s). 모르면 null.
  final double? speedMps;

  GeoPoint get point => GeoPoint(lat, lng);
}

/// 경로 기록의 기본 기준값. 현장 테스트(F2) 후 조정한다.
abstract final class TrackConfig {
  /// 이보다 오차가 큰 점은 버린다.
  static const maxAccuracyM = 50.0;

  /// 앞 점에서 이 속도(m/s)보다 빠르게 튄 점은 GPS 오류로 보고 버린다. (약 144km/h)
  static const maxPlausibleSpeedMps = 40.0;

  /// 포인트 후보: 이 반경 안에서 이 시간 이상 머물면 후보.
  static const candidateRadiusM = 30.0;
  static const candidateMinDwell = Duration(minutes: 10);

  /// 저장할 때 경로를 단순화하는 허용 오차.
  static const simplifyToleranceM = 5.0;
}

/// 속도에 따른 수집 주기. 멈춰 있으면 드물게, 움직이면 촘촘하게 모아 배터리를 아낀다.
Duration samplingInterval(double? speedMps) {
  final v = speedMps ?? 0;
  if (v < 0.5) return const Duration(seconds: 30); // 정지·낚시 중
  if (v < 2) return const Duration(seconds: 10); // 걷기
  return const Duration(seconds: 5); // 차·배
}

/// 점을 기록해도 되는지. [prev]는 마지막으로 받아들인 점.
bool acceptSample(LocationSample? prev, LocationSample s) {
  final acc = s.accuracyM;
  if (acc != null && acc > TrackConfig.maxAccuracyM) return false;
  if (prev == null) return true;

  final dt = s.time.difference(prev.time).inMilliseconds / 1000;
  if (dt <= 0) return false; // 시간이 거꾸로 가거나 같은 점
  if (dt < samplingInterval(prev.speedMps).inSeconds) return false; // 너무 이름
  final speed = prev.point.distanceTo(s.point) / dt;
  return speed <= TrackConfig.maxPlausibleSpeedMps;
}

double totalDistanceM(List<LocationSample> samples) {
  var sum = 0.0;
  for (var i = 1; i < samples.length; i++) {
    sum += samples[i - 1].point.distanceTo(samples[i].point);
  }
  return sum;
}

/// 머문 자리 후보.
class CandidateDraft {
  const CandidateDraft({
    required this.lat,
    required this.lng,
    required this.dwell,
  });

  final double lat;
  final double lng;
  final Duration dwell;
}

/// 시작 점에서 [radiusM] 안에 [minDwell] 이상 머문 구간의 중심을 후보로 만든다.
/// 구간을 벗어난 점에서 다시 시작한다.
List<CandidateDraft> detectCandidates(
  List<LocationSample> samples, {
  double radiusM = TrackConfig.candidateRadiusM,
  Duration minDwell = TrackConfig.candidateMinDwell,
}) {
  final result = <CandidateDraft>[];
  var start = 0;
  while (start < samples.length) {
    final anchor = samples[start].point;
    var end = start;
    while (end + 1 < samples.length &&
        anchor.distanceTo(samples[end + 1].point) <= radiusM) {
      end++;
    }
    final dwell = samples[end].time.difference(samples[start].time);
    if (dwell >= minDwell) {
      final cluster = samples.sublist(start, end + 1);
      result.add(CandidateDraft(
        lat: cluster.map((e) => e.lat).reduce((a, b) => a + b) / cluster.length,
        lng: cluster.map((e) => e.lng).reduce((a, b) => a + b) / cluster.length,
        dwell: dwell,
      ));
    }
    start = end + 1;
  }
  return result;
}

/// 기록을 끝냈을 때의 결과.
class TrackResult {
  const TrackResult({
    required this.startedAt,
    required this.endedAt,
    required this.distanceM,
    required this.encodedPolyline,
    required this.candidates,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceM;

  /// 5m 허용 오차로 단순화한 경로(Encoded Polyline).
  final String encodedPolyline;
  final List<CandidateDraft> candidates;
}

/// 한 번의 경로 기록. 점을 받아 걸러 쌓고, 끝나면 결과를 만든다.
class TrackSession {
  TrackSession({required this.startedAt});

  final DateTime startedAt;
  final List<LocationSample> _samples = [];
  bool paused = false;

  List<LocationSample> get samples => List.unmodifiable(_samples);
  LocationSample? get last => _samples.isEmpty ? null : _samples.last;
  double get distanceM => totalDistanceM(_samples);

  Duration get elapsed => (last?.time ?? startedAt).difference(startedAt);

  /// 받아들였으면 true. 일시정지 중이거나 걸러진 점은 false.
  bool add(LocationSample s) {
    if (paused) return false;
    if (!acceptSample(last, s)) return false;
    _samples.add(s);
    return true;
  }

  TrackResult finish() {
    final simplified = simplifyPolyline(
      [for (final s in _samples) s.point],
      TrackConfig.simplifyToleranceM,
    );
    return TrackResult(
      startedAt: startedAt,
      endedAt: last?.time ?? startedAt,
      distanceM: distanceM,
      encodedPolyline: PolylineCodec.encode(simplified),
      candidates: detectCandidates(_samples),
    );
  }
}
