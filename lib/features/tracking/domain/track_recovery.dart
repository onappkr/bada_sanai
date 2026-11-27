import 'track_logic.dart';
import 'tracking_ports.dart';

/// 중단된 기록을 복구한 결과.
enum RecoveryOutcome {
  /// 남은 점으로 경로와 후보를 만들어 저장했다.
  saved,

  /// 남은 점이 없어 기록을 버렸다.
  discarded,
}

/// 중단된 기록을 임시 버퍼의 점으로 마무리해 저장한다. 남은 점이 없으면 버린다.
/// 점은 기록할 때 이미 걸러져 있으므로 다시 걸러내지 않는다.
Future<RecoveryOutcome> recoverTrack(TrackRepository repo, InterruptedTrack track) async {
  final samples = await repo.bufferedSamples(track.id);
  if (samples.isEmpty) {
    await repo.discard(track.id);
    return RecoveryOutcome.discarded;
  }
  await repo.finish(track.id, summarizeTrack(track.startedAt, samples));
  return RecoveryOutcome.saved;
}
