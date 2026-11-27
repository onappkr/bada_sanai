import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/point/data/drift_point_repository.dart';
import 'package:bada_sanai/features/tracking/data/drift_track_repository.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// SQLite가 되는 환경(CI 등)에서 도는 트랙 저장소 테스트.
void main() {
  late AppDatabase db;
  late DriftTrackRepository repo;
  late DriftPointRepository points;

  final t0 = DateTime.utc(2026, 11, 27, 6);
  LocationSample s(int min) =>
      LocationSample(lat: 35.1, lng: 129.0, time: t0.add(Duration(minutes: min)));

  TrackResult result({int candidates = 1}) => TrackResult(
        startedAt: t0,
        endedAt: t0.add(const Duration(minutes: 12)),
        distanceM: 120,
        encodedPolyline: '_p~iF~ps|U',
        candidates: [
          for (var i = 0; i < candidates; i++)
            CandidateDraft(lat: 35.1 + i * 0.01, lng: 129.0, dwell: Duration(minutes: 11 + i)),
        ],
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTrackRepository(db);
    points = DriftPointRepository(db);
  });
  tearDown(() => db.close());

  test('기록하는 동안 점이 쌓이고, 종료하면 임시 점이 지워지고 후보가 생긴다', () async {
    final id = await repo.start(t0);
    await repo.addSample(id, s(0));
    await repo.addSample(id, s(1));
    expect((await db.select(db.trackPoints).get()).length, 2);

    await repo.finish(id, result(candidates: 2));
    expect(await db.select(db.trackPoints).get(), isEmpty);
    final track = await db.select(db.tracks).getSingle();
    expect(track.status, TrackStatus.saved);
    expect(track.distanceM, 120);
    expect(track.encodedPolyline, '_p~iF~ps|U');
    final cands = await repo.watchPendingCandidates(id).first;
    expect(cands.length, 2);
    // 오래 머문 순서
    expect(cands.first.dwell, const Duration(minutes: 12));
  });

  test('없는 트랙을 끝내려 하면 StateError', () {
    expect(() => repo.finish('none', result()), throwsStateError);
  });

  test('버리면 상태가 버려짐이 되고 임시 점이 지워진다', () async {
    final id = await repo.start(t0);
    await repo.addSample(id, s(0));
    await repo.discard(id);
    expect((await db.select(db.tracks).getSingle()).status, TrackStatus.discarded);
    expect(await db.select(db.trackPoints).get(), isEmpty);
  });

  test('후보를 확정하면 자동 저장 포인트가 생기고 후보는 목록에서 사라진다', () async {
    final id = await repo.start(t0);
    await repo.finish(id, result());
    final c = (await repo.watchPendingCandidates(id).first).single;

    final pointId = await repo.confirmCandidate(c.id, '  새 자리  ');
    final p = (await points.watchOne(pointId).first)!;
    expect(p.name, '새 자리');
    expect(p.source, PointSource.auto);
    expect(p.lat, closeTo(35.1, 1e-9));
    expect(await repo.watchPendingCandidates(id).first, isEmpty);
  });

  test('이름이 비면 확정되지 않고 후보가 남는다', () async {
    final id = await repo.start(t0);
    await repo.finish(id, result());
    final c = (await repo.watchPendingCandidates(id).first).single;
    await expectLater(repo.confirmCandidate(c.id, '  '), throwsArgumentError);
    expect((await repo.watchPendingCandidates(id).first).length, 1);
    expect(await points.watchAll().first, isEmpty);
  });

  test('이미 처리한 후보는 다시 확정할 수 없다', () async {
    final id = await repo.start(t0);
    await repo.finish(id, result());
    final c = (await repo.watchPendingCandidates(id).first).single;
    await repo.confirmCandidate(c.id, '곳');
    await expectLater(repo.confirmCandidate(c.id, '또'), throwsStateError);
    expect((await points.watchAll().first).length, 1);
  });

  test('후보를 버리면 포인트 없이 목록에서만 사라진다', () async {
    final id = await repo.start(t0);
    await repo.finish(id, result());
    final c = (await repo.watchPendingCandidates(id).first).single;
    await repo.dismissCandidate(c.id);
    expect(await repo.watchPendingCandidates(id).first, isEmpty);
    expect(await points.watchAll().first, isEmpty);
  });

  test('기록 중으로 남은 트랙과 임시 점을 중단된 기록으로 찾는다', () async {
    final id = await repo.start(t0);
    await repo.addSample(id, s(1));
    await repo.addSample(id, s(0));
    final done = await repo.start(t0.add(const Duration(hours: 1)));
    await repo.finish(done, result());

    final found = await repo.findInterrupted();
    expect(found.map((e) => e.id), [id]); // 끝낸 트랙은 제외
    expect(found.single.sampleCount, 2);

    final samples = await repo.bufferedSamples(id);
    expect(samples.map((e) => e.time.minute), [0, 1]); // 기록 시각 순
  });

  test('저장된 경로만 최근 시작 순으로 보이고, 버린 경로는 사라진다', () async {
    final a = await repo.start(t0);
    final b = await repo.start(t0.add(const Duration(days: 1)));
    final c = await repo.start(t0.add(const Duration(days: 2))); // 끝내지 않음
    await repo.finish(a, result());
    await repo.finish(b, result());

    var saved = await repo.watchSavedTracks().first;
    expect(saved.map((e) => e.id), [b, a]);
    expect(saved.first.distanceM, 120);
    expect(saved.first.encodedPolyline, '_p~iF~ps|U');
    expect(saved.first.duration, const Duration(minutes: 12));
    expect(saved.any((e) => e.id == c), isFalse);

    await repo.discard(a);
    saved = await repo.watchSavedTracks().first;
    expect(saved.map((e) => e.id), [b]);
    expect(await repo.watchSavedTrack(a).first, isNull);
  });
}
