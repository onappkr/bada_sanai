import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/backup/data/drift_backup_repository.dart';
import 'package:bada_sanai/features/backup/domain/backup_models.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// 병합 복원 규칙 테스트. SQLite가 되는 환경(CI 등)에서 돈다.
void main() {
  late AppDatabase db;
  late DriftBackupRepository repo;

  final t0 = DateTime.utc(2026, 11, 1);
  final t1 = DateTime.utc(2026, 11, 2);

  Point point(String id, {String name = '곳', DateTime? at}) => Point(
        id: id,
        name: name,
        lat: 35,
        lng: 129,
        genre: null,
        memo: null,
        source: PointSource.manual,
        createdAt: t0,
        updatedAt: at ?? t0,
        deletedAt: null,
      );

  CatchLog log(String id, {String? pointId, DateTime? at}) => CatchLog(
        id: id,
        genre: Genre.lure,
        fishedAt: t0,
        pointId: pointId,
        lat: null,
        lng: null,
        memo: null,
        genreDetail: '{}',
        env: '{}',
        createdAt: t0,
        updatedAt: at ?? t0,
        deletedAt: null,
      );

  CatchItem item(String id, String logId, String species) => CatchItem(
      id: id, logId: logId, speciesCode: species, lengthCm: null, count: 1, memo: null);

  Photo photo(String id, String ownerId, {OwnerType type = OwnerType.log}) => Photo(
        id: id,
        ownerType: type,
        ownerId: ownerId,
        filePath: 'photos/$id.jpg',
        width: null,
        height: null,
        createdAt: t0,
      );

  BackupSnapshot snap({
    List<Point> points = const [],
    List<CatchLog> logs = const [],
    List<CatchItem> items = const [],
    List<Photo> photos = const [],
  }) =>
      BackupSnapshot(exportedAt: t1, points: points, logs: logs, items: items, photos: photos);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftBackupRepository(db);
  });
  tearDown(() => db.close());

  test('빈 기기에 복원하면 모두 추가된다', () async {
    final r = await repo.restore(snap(
      points: [point('p1')],
      logs: [log('l1', pointId: 'p1')],
      items: [item('i1', 'l1', 'seabass')],
    ));
    expect((r.added, r.updated, r.skipped), (2, 0, 0));
    final back = await repo.snapshot();
    expect(back.items.single.speciesCode, 'seabass');
    expect(back.logs.single.pointId, 'p1');
  });

  test('같은 백업을 다시 복원하면 모두 건너뛴다(여러 번 해도 안전)', () async {
    final s = snap(points: [point('p1')], logs: [log('l1')], items: [item('i1', 'l1', 'a')]);
    await repo.restore(s);
    final r = await repo.restore(s);
    expect((r.added, r.updated, r.skipped), (0, 0, 2));
    expect((await repo.snapshot()).items.length, 1);
  });

  test('기기 쪽이 더 최신이면 건드리지 않고, 백업이 더 최신이면 갱신한다', () async {
    await repo.restore(snap(points: [point('p1', name: '기기', at: t1)]));
    var r = await repo.restore(snap(points: [point('p1', name: '옛 백업', at: t0)]));
    expect(r.skipped, 1);
    expect((await repo.snapshot()).points.single.name, '기기');

    r = await repo.restore(
        snap(points: [point('p1', name: '새 백업', at: DateTime.utc(2026, 11, 3))]));
    expect(r.updated, 1);
    expect((await repo.snapshot()).points.single.name, '새 백업');
  });

  test('일지가 갱신되면 조과가 백업 내용으로 교체되고, 건너뛰면 그대로다', () async {
    await repo.restore(snap(logs: [log('l1')], items: [item('i1', 'l1', 'old')]));

    await repo.restore(snap(logs: [log('l1', at: t1)], items: [item('i2', 'l1', 'new')]));
    expect((await repo.snapshot()).items.map((e) => e.speciesCode), ['new']);

    await repo.restore(snap(logs: [log('l1', at: t0)], items: [item('i3', 'l1', 'older')]));
    expect((await repo.snapshot()).items.map((e) => e.speciesCode), ['new']);
  });

  test('참조하는 포인트가 어디에도 없으면 연결만 끊고 일지는 살린다', () async {
    final r = await repo.restore(snap(logs: [log('l1', pointId: 'ghost')]));
    expect(r.added, 1);
    expect((await repo.snapshot()).logs.single.pointId, isNull);
  });

  test('삭제 표시가 더 최신이면 기기에도 삭제가 전달된다', () async {
    await repo.restore(snap(logs: [log('l1')]));
    final deleted = log('l1', at: t1).copyWith(deletedAt: Value(t1));
    await repo.restore(snap(logs: [deleted]));
    expect((await repo.snapshot()).logs.single.deletedAt, isNotNull);
  });

  test('사진: 일지·포인트에 연결해 복원하고, 같은 id는 중복하지 않는다', () async {
    final data = snap(
      points: [point('p1')],
      logs: [log('l1')],
      photos: [photo('a', 'l1'), photo('b', 'p1', type: OwnerType.point)],
    );
    final r = await repo.restore(data);
    expect(r.photosAdded, 2);
    expect((await repo.snapshot()).photos.map((e) => e.id).toSet(), {'a', 'b'});

    final again = await repo.restore(data);
    expect(again.photosAdded, 0);
    expect((await repo.snapshot()).photos.length, 2);
  });

  test('사진: 주인이 없는 사진은 연결하지 않는다', () async {
    final r = await repo.restore(snap(photos: [photo('x', 'ghost')]));
    expect(r.photosAdded, 0);
    expect((await repo.snapshot()).photos, isEmpty);
  });
}
