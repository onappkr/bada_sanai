import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/catch_log/data/drift_catch_log_repository.dart';
import 'package:bada_sanai/features/catch_log/domain/catch_log_models.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late DriftCatchLogRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftCatchLogRepository(db);
  });
  tearDown(() => db.close());

  CatchLogInput input({
    Genre genre = Genre.lure,
    DateTime? at,
    List<CatchItemInput> items = const [],
  }) =>
      CatchLogInput(
        genre: genre,
        fishedAt: at ?? DateTime.utc(2026, 11, 1, 6),
        memo: '  바람 강함  ',
        genreDetail: const {'lure': '지그헤드', 'rod': ' '},
        items: items,
      );

  test('생성 후 조회: 메모는 공백 제거, 빈 상세 항목은 저장하지 않음', () async {
    final id = await repo.create(input(items: const [
      CatchItemInput(speciesCode: 'seabass', lengthCm: 55.5, count: 2),
    ]));
    final log = (await repo.watchOne(id).first)!;
    expect(log.memo, '바람 강함');
    expect(log.genreDetail, {'lure': '지그헤드'});
    expect(log.items.single.speciesCode, 'seabass');
    expect(log.items.single.lengthCm, 55.5);
    expect(log.totalCount, 2);
  });

  test('목록은 낚시 시각 내림차순, 장르 필터 적용', () async {
    await repo.create(input(at: DateTime.utc(2026, 10, 1)));
    await repo.create(input(genre: Genre.cast, at: DateTime.utc(2026, 11, 1)));

    final all = await repo.watchAll().first;
    expect(all.map((e) => e.genre), [Genre.cast, Genre.lure]);

    final lure = await repo.watchAll(genre: Genre.lure).first;
    expect(lure.single.genre, Genre.lure);
  });

  test('수정하면 조과 항목이 교체된다', () async {
    final id = await repo.create(input(items: const [
      CatchItemInput(speciesCode: 'seabass'),
      CatchItemInput(speciesCode: 'flatfish'),
    ]));
    await repo.update(
        id, input(items: const [CatchItemInput(speciesCode: 'squid', count: 3)]));
    final log = (await repo.watchOne(id).first)!;
    expect(log.items.map((e) => e.speciesCode), ['squid']);
    expect(log.items.single.count, 3);
  });

  test('삭제하면 목록과 단건 조회에서 사라진다', () async {
    final id = await repo.create(input());
    await repo.delete(id);
    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchOne(id).first, isNull);
  });

  test('없는 일지 수정은 StateError', () async {
    expect(() => repo.update('none', input()), throwsStateError);
  });
}
