import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/point/data/drift_point_repository.dart';
import 'package:bada_sanai/features/share/data/drift_share_import_repository.dart';
import 'package:bada_sanai/features/share/domain/shared_point.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late DriftShareImportRepository repo;
  late DriftPointRepository points;

  const shared = SharedPoint(name: '받은 곳', lat: 35.1, lng: 129.0, memo: '메모');

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftShareImportRepository(db);
    points = DriftPointRepository(db);
  });
  tearDown(() => db.close());

  test('처음 받으면 출처가 공유 받음인 포인트가 생긴다', () async {
    final r = await repo.import(shared, 'fp1');
    expect(r.alreadyImported, isFalse);
    final p = (await points.watchOne(r.pointId).first)!;
    expect(p.name, '받은 곳');
    expect(p.source, PointSource.shared);
    expect(p.memo, '메모');
  });

  test('같은 링크를 다시 받으면 새로 만들지 않고 기존 포인트를 돌려준다', () async {
    final a = await repo.import(shared, 'fp1');
    final b = await repo.import(shared, 'fp1');
    expect(b.alreadyImported, isTrue);
    expect(b.pointId, a.pointId);
    expect((await points.watchAll().first).length, 1);
  });

  test('다른 링크는 따로 저장된다', () async {
    await repo.import(shared, 'fp1');
    await repo.import(shared, 'fp2');
    expect((await points.watchAll().first).length, 2);
  });

  test('받은 포인트를 지운 뒤에는 같은 링크로 다시 받을 수 있다', () async {
    final a = await repo.import(shared, 'fp1');
    await points.delete(a.pointId);
    final b = await repo.import(shared, 'fp1');
    expect(b.alreadyImported, isFalse);
    expect(b.pointId, isNot(a.pointId));
    expect((await points.watchAll().first).length, 1);
  });
}
