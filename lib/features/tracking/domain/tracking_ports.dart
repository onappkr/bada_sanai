import 'track_logic.dart';

/// 머문 자리 후보(저장소에서 읽은 값).
class CandidateView {
  const CandidateView({
    required this.id,
    required this.trackId,
    required this.lat,
    required this.lng,
    required this.dwell,
  });

  final String id;
  final String trackId;
  final double lat;
  final double lng;
  final Duration dwell;
}

/// 저장이 끝난 경로 한 건.
class SavedTrack {
  const SavedTrack({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.distanceM,
    required this.encodedPolyline,
  });

  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final double distanceM;

  /// 단순화한 경로(Encoded Polyline). 점이 없었다면 빈 문자열.
  final String encodedPolyline;

  Duration get duration => endedAt.difference(startedAt);
}

/// 앱이 중간에 종료되어 끝맺지 못한 기록.
class InterruptedTrack {
  const InterruptedTrack({
    required this.id,
    required this.startedAt,
    required this.sampleCount,
  });

  final String id;
  final DateTime startedAt;

  /// 임시 버퍼에 남아 있는 점 개수.
  final int sampleCount;
}

abstract interface class TrackRepository {
  /// 기록을 시작한다(상태: 기록 중). 새 트랙 id를 돌려준다.
  Future<String> start(DateTime startedAt);

  /// 기록 중 임시 버퍼에 점을 쌓는다. 앱이 죽어도 점이 남는다.
  Future<void> addSample(String trackId, LocationSample sample);

  /// 결과를 저장한다: 트랙을 '저장됨'으로 바꾸고, 임시 점을 지우고, 후보를 만든다.
  Future<void> finish(String trackId, TrackResult result);

  /// 기록을 버린다(임시 점 포함).
  Future<void> discard(String trackId);

  /// 확정을 기다리는 후보.
  Stream<List<CandidateView>> watchPendingCandidates(String trackId);

  /// 후보를 이름 붙여 포인트(출처: 자동 저장)로 저장한다. 새 포인트 id를 돌려준다.
  /// 이름이 비었으면 [ArgumentError].
  Future<String> confirmCandidate(String candidateId, String name);

  /// 후보를 버린다.
  Future<void> dismissCandidate(String candidateId);

  /// 저장이 끝난 경로를 시작 시각 내림차순으로 관찰한다.
  Stream<List<SavedTrack>> watchSavedTracks();

  Stream<SavedTrack?> watchSavedTrack(String trackId);

  /// '기록 중' 상태로 남은 트랙(앱이 도중에 꺼진 경우). 오래된 순.
  Future<List<InterruptedTrack>> findInterrupted();

  /// 임시 버퍼의 점을 기록 순서대로 읽는다.
  Future<List<LocationSample>> bufferedSamples(String trackId);
}

/// 위치 측정값을 흘려보내는 원천. 실제 구현은 GPS, 미리보기·테스트는 가짜.
abstract interface class LocationSource {
  /// 구독하는 동안 측정값을 보낸다. 권한이 없거나 위치가 꺼져 있으면 오류를 흘린다.
  Stream<LocationSample> watch();
}
