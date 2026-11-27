import 'package:bada_sanai/features/point/data/in_memory_point_repository.dart';
import 'package:bada_sanai/features/tracking/data/in_memory_tracking.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:bada_sanai/features/tracking/domain/track_recovery.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

LocationSample at(int minutes, {double northM = 0}) => LocationSample(
      lat: 35.0 + northM / 111195,
      lng: 129.0,
      time: t0.add(Duration(minutes: minutes)),
    );

void main() {
  late InMemoryTrackRepository repo;

  setUp(() => repo = InMemoryTrackRepository(InMemoryPointRepository()));

  test('summarizeTrack은 TrackSession.finish와 같은 결과를 낸다', () {
    final session = TrackSession(startedAt: t0);
    final samples = [for (var i = 0; i <= 12; i++) at(i)];
    for (final s in samples) {
      session.add(s);
    }
    final a = session.finish();
    final b = summarizeTrack(t0, session.samples);
    expect(b.distanceM, a.distanceM);
    expect(b.encodedPolyline, a.encodedPolyline);
    expect(b.candidates.length, a.candidates.length);
    expect(b.endedAt, a.endedAt);
  });

  test('점이 없으면 시작 시각으로 끝나고 거리 0', () {
    final r = summarizeTrack(t0, const []);
    expect(r.endedAt, t0);
    expect(r.distanceM, 0);
    expect(r.candidates, isEmpty);
  });

  test('기록 중에 남은 트랙이 중단된 기록으로 보인다', () async {
    final id = await repo.start(t0);
    await repo.addSample(id, at(0));
    await repo.addSample(id, at(1));
    final found = await repo.findInterrupted();
    expect(found.single.id, id);
    expect(found.single.sampleCount, 2);
    expect(found.single.startedAt, t0);
  });

  test('정상 종료하거나 버린 트랙은 중단된 기록이 아니다', () async {
    final a = await repo.start(t0);
    final b = await repo.start(t0.add(const Duration(hours: 1)));
    await repo.finish(a, summarizeTrack(t0, const []));
    await repo.discard(b);
    expect(await repo.findInterrupted(), isEmpty);
  });

  test('오래된 순으로 돌려준다', () async {
    final later = await repo.start(t0.add(const Duration(days: 1)));
    final earlier = await repo.start(t0);
    expect((await repo.findInterrupted()).map((e) => e.id), [earlier, later]);
  });

  test('복구: 남은 점으로 경로와 후보를 저장하고 더는 중단된 기록이 아니다', () async {
    final id = await repo.start(t0);
    for (var i = 0; i <= 12; i++) {
      await repo.addSample(id, at(i)); // 12분 머묾
    }
    final track = (await repo.findInterrupted()).single;

    expect(await recoverTrack(repo, track), RecoveryOutcome.saved);
    expect(await repo.findInterrupted(), isEmpty);
    final candidates = await repo.watchPendingCandidates(id).first;
    expect(candidates.length, 1);
    expect(candidates.single.dwell, const Duration(minutes: 12));
  });

  test('복구: 남은 점이 없으면 버린다', () async {
    final id = await repo.start(t0);
    final track = (await repo.findInterrupted()).single;
    expect(await recoverTrack(repo, track), RecoveryOutcome.discarded);
    expect(await repo.findInterrupted(), isEmpty);
    expect(await repo.watchPendingCandidates(id).first, isEmpty);
  });
}
