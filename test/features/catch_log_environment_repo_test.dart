import 'package:bada_sanai/features/catch_log/data/in_memory_catch_log_repository.dart';
import 'package:bada_sanai/features/catch_log/domain/catch_log_models.dart';
import 'package:bada_sanai/features/catch_log/domain/log_environment.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_models.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

LogEnvironment env({double lat = 35.01}) => LogEnvironment(
      lat: lat,
      lng: 129.01,
      forecast: ForecastBundle(
        regionCode: 'R-1',
        date: '2026-11-27',
        fetchedAt: t0,
        stale: false,
        tide: const TideInfo(mulddae: 9),
        seaTempC: 16.4,
      ),
    );

CatchLogInput input({LogEnvironment? environment}) => CatchLogInput(
      genre: Genre.lure,
      fishedAt: t0,
      environment: environment,
    );

/// 메모리 저장소로 "환경은 처음에만 붙고 수정해도 유지된다"는 규칙을 시험한다.
/// (Drift 저장소의 같은 규칙은 catch_log_repository_test.dart의 CI 시험이 확인한다.)
void main() {
  late InMemoryCatchLogRepository repo;
  setUp(() => repo = InMemoryCatchLogRepository());

  test('새 일지에 붙인 환경이 그대로 읽힌다', () async {
    final id = await repo.create(input(environment: env()));
    final log = (await repo.watchOne(id).first)!;
    expect(log.environment!.lat, 35.01);
    expect(log.environment!.forecast!.tide!.mulddae, 9);
    expect(log.environment!.forecast!.seaTempC, 16.4);
  });

  test('환경 없이 만든 일지는 environment가 null', () async {
    final id = await repo.create(input());
    expect((await repo.watchOne(id).first)!.environment, isNull);
  });

  test('수정할 때 환경을 주지 않으면 저장된 환경을 유지한다', () async {
    final id = await repo.create(input(environment: env()));
    await repo.update(id, input()); // 환경 없는 입력으로 수정
    final log = (await repo.watchOne(id).first)!;
    expect(log.environment!.lat, 35.01);
    expect(log.environment!.forecast, isNotNull);
  });

  test('toInput으로 되돌려 수정해도 환경이 유지된다', () async {
    final id = await repo.create(input(environment: env()));
    final log = (await repo.watchOne(id).first)!;
    await repo.update(id, log.toInput());
    expect((await repo.watchOne(id).first)!.environment!.lng, 129.01);
  });

  test('수정할 때 새 환경을 주면 바뀐다', () async {
    final id = await repo.create(input(environment: env()));
    await repo.update(id, input(environment: env(lat: 36.0)));
    expect((await repo.watchOne(id).first)!.environment!.lat, 36.0);
  });
}
