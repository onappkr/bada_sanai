import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/point/data/drift_point_repository.dart';
import 'package:bada_sanai/features/point/domain/point_models.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late DriftPointRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftPointRepository(db);
  });
  tearDown(() => db.close());

  PointInput input({String name = '방파제', double lat = 35.1, double lng = 129.0}) =>
      PointInput(name: name, lat: lat, lng: lng, memo: '  ');

  test('생성 후 조회: 이름 공백 제거, 빈 메모는 null', () async {
    final id = await repo.create(input(name: '  영도  '));
    final p = (await repo.watchOne(id).first)!;
    expect(p.name, '영도');
    expect(p.memo, isNull);
    expect(p.source, PointSource.manual);
  });

  test('목록은 이름순', () async {
    await repo.create(input(name: '나'));
    await repo.create(input(name: '가'));
    expect((await repo.watchAll().first).map((e) => e.name), ['가', '나']);
  });

  test('잘못된 좌표·이름은 ArgumentError', () {
    expect(() => repo.create(input(lat: 91)), throwsArgumentError);
    expect(() => repo.create(input(lng: -181)), throwsArgumentError);
    expect(() => repo.create(input(name: ' ')), throwsArgumentError);
  });

  test('수정과 삭제', () async {
    final id = await repo.create(input());
    await repo.update(id, input(name: '새 이름'));
    expect((await repo.watchOne(id).first)!.name, '새 이름');
    await repo.delete(id);
    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchOne(id).first, isNull);
  });

  test('없는 포인트 수정은 StateError', () {
    expect(() => repo.update('none', input()), throwsStateError);
  });
}
