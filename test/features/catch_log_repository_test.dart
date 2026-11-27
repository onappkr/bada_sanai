import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/catch_log/data/drift_catch_log_repository.dart';
import 'package:bada_sanai/features/catch_log/domain/catch_log_models.dart';
import 'package:bada_sanai/features/catch_log/domain/log_environment.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_models.dart';
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

  test('포인트별 일지 조회', () async {
    await db.into(db.points).insert(PointsCompanion.insert(
          id: 'p1',
          name: '방파제',
          lat: 35,
          lng: 129,
          source: PointSource.manual,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ));
    await repo.create(CatchLogInput(
        genre: Genre.lure, fishedAt: DateTime.utc(2026, 11, 1), pointId: 'p1'));
    await repo.create(
        CatchLogInput(genre: Genre.lure, fishedAt: DateTime.utc(2026, 11, 2)));

    final linked = await repo.watchAll(pointId: 'p1').first;
    expect(linked.length, 1);
    expect(linked.single.pointId, 'p1');
    expect((await repo.watchAll().first).length, 2);
  });

  group('환경 자동 기록(위치·예보)', () {
    LogEnvironment env({double lat = 35.01}) => LogEnvironment(
          lat: lat,
          lng: 129.01,
          forecast: ForecastBundle(
            regionCode: 'R-1',
            date: '2026-11-27',
            fetchedAt: DateTime.utc(2026, 11, 27, 6),
            stale: false,
            tide: const TideInfo(mulddae: 9),
            seaTempC: 16.4,
          ),
        );

    test('새 일지에 붙인 환경이 lat·lng·env 열에 저장되고 다시 읽힌다', () async {
      final id = await repo.create(input().withEnvironment(env()));
      final row = await (db.select(db.catchLogs)..where((t) => t.id.equals(id))).getSingle();
      expect(row.lat, 35.01);
      expect(row.lng, 129.01);
      expect(row.env, contains('forecast'));

      final log = (await repo.watchOne(id).first)!;
      expect(log.environment!.forecast!.tide!.mulddae, 9);
      expect(log.environment!.forecast!.seaTempC, 16.4);
    });

    test('환경 없이 만든 일지는 열이 비고 environment는 null', () async {
      final id = await repo.create(input());
      final row = await (db.select(db.catchLogs)..where((t) => t.id.equals(id))).getSingle();
      expect(row.lat, isNull);
      expect(row.env, '{}');
      expect((await repo.watchOne(id).first)!.environment, isNull);
    });

    test('수정할 때 환경을 주지 않으면 저장된 환경을 유지한다', () async {
      final id = await repo.create(input().withEnvironment(env()));
      await repo.update(id, input()); // 환경 없는 입력
      final log = (await repo.watchOne(id).first)!;
      expect(log.environment!.lat, 35.01);
      expect(log.environment!.forecast, isNotNull);
    });

    test('수정할 때 새 환경을 주면 바뀐다', () async {
      final id = await repo.create(input().withEnvironment(env()));
      await repo.update(id, input().withEnvironment(env(lat: 36.0)));
      expect((await repo.watchOne(id).first)!.environment!.lat, 36.0);
    });
  });
}

extension on CatchLogInput {
  CatchLogInput withEnvironment(LogEnvironment e) => CatchLogInput(
        genre: genre,
        fishedAt: fishedAt,
        pointId: pointId,
        memo: memo,
        genreDetail: genreDetail,
        items: items,
        environment: e,
      );
}
