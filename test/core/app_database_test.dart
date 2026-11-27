import 'package:bada_sanai/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 11, 27);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  PointsCompanion point(String id) => PointsCompanion.insert(
        id: id,
        name: '포인트$id',
        lat: 35.1,
        lng: 129.0,
        source: PointSource.manual,
        createdAt: now,
        updatedAt: now,
      );

  test('포인트 저장·조회 및 enum 왕복', () async {
    await db.into(db.points).insert(point('p1'));
    final p = await (db.select(db.points)..where((t) => t.id.equals('p1')))
        .getSingle();
    expect(p.source, PointSource.manual);
    expect(p.genre, isNull);
  });

  test('일지 삭제 시 어종 항목도 함께 삭제(cascade)', () async {
    await db.into(db.catchLogs).insert(CatchLogsCompanion.insert(
          id: 'l1',
          genre: Genre.lure,
          fishedAt: now,
          createdAt: now,
          updatedAt: now,
        ));
    await db.into(db.catchItems).insert(CatchItemsCompanion.insert(
          id: 'i1',
          logId: 'l1',
          speciesCode: 'seabass',
        ));
    await (db.delete(db.catchLogs)..where((t) => t.id.equals('l1'))).go();
    expect(await db.select(db.catchItems).get(), isEmpty);
  });

  test('존재하지 않는 포인트를 참조하면 외래키 오류', () async {
    expect(
      () => db.into(db.shareImports).insert(ShareImportsCompanion.insert(
            id: 's1',
            pointId: 'none',
            payloadHash: 'h',
            importedAt: now,
          )),
      throwsA(isA<Exception>()),
    );
  });

  test('같은 공유 링크 해시는 중복 저장 불가', () async {
    await db.into(db.points).insert(point('p1'));
    ShareImportsCompanion imp(String id) => ShareImportsCompanion.insert(
        id: id, pointId: 'p1', payloadHash: 'same', importedAt: now);
    await db.into(db.shareImports).insert(imp('s1'));
    expect(() => db.into(db.shareImports).insert(imp('s2')),
        throwsA(isA<Exception>()));
  });

  test('기록 중 버퍼는 트랙 삭제 시 함께 삭제', () async {
    await db.into(db.tracks).insert(TracksCompanion.insert(
        id: 't1',
        startedAt: now,
        status: TrackStatus.recording,
        updatedAt: now));
    await db.into(db.trackPoints).insert(TrackPointsCompanion.insert(
        trackId: 't1', lat: 35, lng: 129, recordedAt: now));
    await (db.delete(db.tracks)..where((t) => t.id.equals('t1'))).go();
    expect(await db.select(db.trackPoints).get(), isEmpty);
  });
}
