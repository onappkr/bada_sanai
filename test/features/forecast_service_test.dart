import 'dart:async';
import 'dart:convert';

import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_models.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_ports.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_service.dart';
import 'package:bada_sanai/features/species/domain/rule_book.dart';
import 'package:test/test.dart';

// 아래 값은 모두 시험용 가짜 값이다(실제 예보가 아니다).
final ruleBook = RuleBook.parse(
  speciesRuleJson: jsonEncode({'version': 1, 'species': [], 'rules': []}),
  regionJson: jsonEncode({
    'version': 1,
    'regions': [
      {
        'code': 'R-1',
        'name_ko': '가해역',
        'center': {'lat': 35.0, 'lng': 129.0},
        'tide_station_id': 'T1',
      },
    ],
  }),
);

const here = GeoPoint(35.01, 129.01); // R-1에서 약 1.4km
const farAway = GeoPoint(33.0, 126.0); // 50km보다 훨씬 멀다

final t0 = DateTime.utc(2026, 11, 27, 1);
final day = DateTime(2026, 11, 27);

final tideA = TideInfo(mulddae: 9, extremes: [
  TideExtreme(time: DateTime.utc(2026, 11, 26, 18, 12), type: TideType.high, heightCm: 245),
]);
const weatherA = WeatherInfo(tempC: 11, windMps: 5.2, waveM: 0.8, sky: 'clear');

class FakeClock {
  DateTime now = t0;
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

class FakeCache implements ForecastCacheStore {
  final map = <String, CachedEntry>{};
  bool corruptReads = false;
  bool failWrites = false;

  @override
  Future<CachedEntry?> get(String key) async {
    final e = map[key];
    if (e == null) return null;
    return corruptReads ? CachedEntry(payload: '{깨짐', fetchedAt: e.fetchedAt, expiresAt: e.expiresAt) : e;
  }

  @override
  Future<void> put(String key, CachedEntry entry) async {
    if (failWrites) throw StateError('디스크 가득');
    map[key] = entry;
  }
}

class FakeSource implements ForecastSource {
  int tideCalls = 0, weatherCalls = 0, seaCalls = 0;
  bool failAll = false;
  int failFirst = 0; // 처음 N번 호출은 실패
  bool hang = false;
  TideInfo? tideValue = tideA;
  WeatherInfo? weatherValue = weatherA;
  double? seaValue = 16.4;

  Future<T?> _run<T>(T? value, void Function() count) async {
    count();
    if (hang) return Completer<T?>().future;
    if (failAll) throw StateError('네트워크 오류');
    if (failFirst > 0) {
      failFirst--;
      throw StateError('일시 오류');
    }
    return value;
  }

  @override
  Future<TideInfo?> tide(RuleRegion region, DateTime date) => _run(tideValue, () => tideCalls++);

  @override
  Future<WeatherInfo?> weather(RuleRegion region, DateTime date) =>
      _run(weatherValue, () => weatherCalls++);

  @override
  Future<double?> seaTemp(RuleRegion region, DateTime date) => _run(seaValue, () => seaCalls++);
}

void main() {
  late FakeClock clock;
  late FakeCache cache;
  late FakeSource source;
  late ForecastService service;

  setUp(() {
    clock = FakeClock();
    cache = FakeCache();
    source = FakeSource();
    service = ForecastService(source: source, cache: cache, ruleBook: ruleBook, clock: clock.call);
  });

  group('정상 흐름', () {
    test('원천에서 가져와 통일 모델로 돌려주고 캐시에 저장한다', () async {
      final b = await service.get(here, day);
      expect(b.regionCode, 'R-1');
      expect(b.date, '2026-11-27');
      expect(b.stale, isFalse);
      expect(b.tide!.mulddae, 9);
      expect(b.weather!.windMps, 5.2);
      expect(b.seaTempC, 16.4);
      expect(b.fetchedAt, t0);
      expect(cache.map.keys, containsAll(['R-1|2026-11-27|tide', 'R-1|2026-11-27|weather', 'R-1|2026-11-27|seatemp']));
    });

    test('유효 시간 안에는 원천을 다시 부르지 않는다', () async {
      await service.get(here, day);
      clock.advance(const Duration(hours: 2)); // 날씨 3h 이내, 수온 6h 이내, 조석 24h 이내
      final b = await service.get(here, day);
      expect((source.tideCalls, source.weatherCalls, source.seaCalls), (1, 1, 1));
      expect(b.stale, isFalse);
    });

    test('항목마다 유효 시간이 달라 만료된 것만 다시 부른다', () async {
      await service.get(here, day);
      clock.advance(const Duration(hours: 4)); // 날씨(3h)만 만료
      await service.get(here, day);
      expect(source.weatherCalls, 2);
      expect(source.tideCalls, 1);
      expect(source.seaCalls, 1);

      clock.advance(const Duration(hours: 3)); // 누적 7h: 수온(6h)도 만료, 날씨는 방금 갱신
      await service.get(here, day);
      expect(source.seaCalls, 2);
      expect(source.tideCalls, 1);
    });

    test('날짜가 다르면 캐시를 따로 쓴다', () async {
      await service.get(here, day);
      await service.get(here, DateTime(2026, 11, 28));
      expect(source.tideCalls, 2);
    });
  });

  group('실패와 오프라인', () {
    test('호출이 실패하면 만료된 캐시를 stale로 돌려주고 마지막 갱신 시각을 유지한다', () async {
      await service.get(here, day);
      clock.advance(const Duration(hours: 30)); // 모두 만료
      source.failAll = true;
      final b = await service.get(here, day);
      expect(b.stale, isTrue);
      expect(b.tide!.mulddae, 9);
      expect(b.fetchedAt, t0); // 새로 가져오지 못해 처음 시각 그대로
    });

    test('일부만 실패하면 실패한 항목만 오래된 캐시를 쓴다', () async {
      await service.get(here, day);
      clock.advance(const Duration(hours: 4)); // 날씨만 만료
      source.failAll = true;
      final b = await service.get(here, day);
      expect(b.stale, isTrue);
      expect(b.weather, isNotNull);
      expect(b.tide, isNotNull); // 아직 유효한 캐시
    });

    test('일시 오류는 1회 재시도로 성공한다', () async {
      source.failFirst = 1;
      final b = await service.get(here, day);
      expect(b.stale, isFalse);
      expect(b.tide, isNotNull);
    });

    test('항목 하나만 계속 실패하면 나머지는 정상으로 돌려준다', () async {
      final partial = FakeSource()..weatherValue = null; // 날씨 값 없음
      final svc = ForecastService(source: partial, cache: FakeCache(), ruleBook: ruleBook, clock: clock.call);
      final b = await svc.get(here, day);
      expect(b.weather, isNull);
      expect(b.tide, isNotNull);
      expect(b.seaTempC, 16.4);
    });

    test('원천이 값 없음(null)이라고 답하면 오래된 캐시를 쓰지 않는다', () async {
      await service.get(here, day);
      clock.advance(const Duration(hours: 4));
      source.weatherValue = null;
      final b = await service.get(here, day);
      expect(b.weather, isNull);
      expect(b.stale, isFalse);
    });

    test('응답이 제한 시간을 넘기면 시간 초과로 보고 캐시로 대신한다', () async {
      await service.get(here, day);
      clock.advance(const Duration(hours: 30));
      source.hang = true;
      final quick = ForecastService(
        source: source,
        cache: cache,
        ruleBook: ruleBook,
        clock: clock.call,
        requestTimeout: const Duration(milliseconds: 50),
      );
      final b = await quick.get(here, day);
      expect(b.stale, isTrue);
      expect(source.tideCalls, 3); // 처음 1번 + 만료 뒤 첫 호출과 재시도(둘 다 시간 초과)
    });
  });

  group('오류 종류', () {
    test('가까운 해역이 없으면 unsupportedRegion', () async {
      await expectLater(
        service.get(farAway, day),
        throwsA(isA<ForecastError>().having((e) => e.kind, 'kind', ForecastErrorKind.unsupportedRegion)),
      );
      expect(source.tideCalls, 0);
    });

    test('원천이 연결 전이고 캐시도 없으면 notConfigured이고 재시도하지 않는다', () async {
      final svc = ForecastService(
        source: _CountingNoSource(),
        cache: FakeCache(),
        ruleBook: ruleBook,
        clock: clock.call,
      );
      await expectLater(
        svc.get(here, day),
        throwsA(isA<ForecastError>().having((e) => e.kind, 'kind', ForecastErrorKind.notConfigured)),
      );
      expect(_CountingNoSource.calls, 3); // 항목당 한 번씩만(재시도 없음)
    });

    test('연결 전이어도 캐시가 있으면 stale로 보여 준다', () async {
      await service.get(here, day);
      clock.advance(const Duration(hours: 30));
      final svc = ForecastService(
        source: const NoForecastSource(),
        cache: cache,
        ruleBook: ruleBook,
        clock: clock.call,
      );
      final b = await svc.get(here, day);
      expect(b.stale, isTrue);
    });

    test('모든 호출이 실패하고 캐시도 없으면 unavailable', () async {
      source.failAll = true;
      await expectLater(
        service.get(here, day),
        throwsA(isA<ForecastError>().having((e) => e.kind, 'kind', ForecastErrorKind.unavailable)),
      );
      expect(source.tideCalls, 2); // 첫 호출 + 재시도 1회
    });

    test('오류 문구는 사용자에게 그대로 보일 수 있다', () {
      for (final k in ForecastErrorKind.values) {
        expect(ForecastError(k).message, isNotEmpty);
      }
    });
  });

  group('캐시 이상', () {
    test('손상된 캐시는 없는 것으로 보고 새로 가져온다', () async {
      await service.get(here, day);
      cache.corruptReads = true;
      final b = await service.get(here, day);
      expect(b.stale, isFalse);
      expect(source.tideCalls, 2);
    });

    test('캐시 저장이 실패해도 값은 돌려준다', () async {
      cache.failWrites = true;
      final b = await service.get(here, day);
      expect(b.tide, isNotNull);
    });
  });

  group('풍향 라벨', () {
    test('8방위로 바꾼다', () {
      expect(windDirectionLabel(0), '북풍');
      expect(windDirectionLabel(45), '북동풍');
      expect(windDirectionLabel(90), '동풍');
      expect(windDirectionLabel(180), '남풍');
      expect(windDirectionLabel(270), '서풍');
      expect(windDirectionLabel(320), '북서풍');
    });

    test('경계는 가까운 방위로, 360도는 북풍', () {
      expect(windDirectionLabel(22), '북풍');
      expect(windDirectionLabel(23), '북동풍');
      expect(windDirectionLabel(359), '북풍');
      expect(windDirectionLabel(360), '북풍');
    });

    test('범위를 벗어난 값도 0~359로 맞춰 읽는다', () {
      expect(windDirectionLabel(450), '동풍');
      expect(windDirectionLabel(-90), '서풍');
    });
  });

  group('모델 JSON', () {
    test('문서 형식과 왕복한다', () {
      final original = ForecastBundle(
        regionCode: 'R-1',
        date: '2026-11-27',
        fetchedAt: t0,
        stale: true,
        tide: tideA,
        weather: weatherA,
        seaTempC: 16.4,
      );
      final back = ForecastBundle.fromJson(jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>);
      expect(back.regionCode, 'R-1');
      expect(back.stale, isTrue);
      expect(back.fetchedAt.isAtSameMomentAs(t0), isTrue);
      expect(back.tide!.extremes.single.type, TideType.high);
      expect(back.tide!.extremes.single.heightCm, 245);
      expect(back.weather!.sky, 'clear');
      expect(back.seaTempC, 16.4);
    });

    test('값이 없는 항목은 null로 읽힌다', () {
      final b = ForecastBundle.fromJson({
        'region_code': 'R-1',
        'date': '2026-11-27',
        'fetched_at': '2026-11-27T01:00:00Z',
      });
      expect(b.tide, isNull);
      expect(b.weather, isNull);
      expect(b.seaTempC, isNull);
      expect(b.stale, isFalse);
    });

    test('날짜 키는 로컬 날짜 기준', () {
      expect(forecastDateKey(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
    });
  });
}

class _CountingNoSource implements ForecastSource {
  static int calls = 0;

  _CountingNoSource() {
    calls = 0;
  }

  @override
  Future<TideInfo?> tide(RuleRegion region, DateTime date) {
    calls++;
    throw const ForecastNotConfigured();
  }

  @override
  Future<WeatherInfo?> weather(RuleRegion region, DateTime date) {
    calls++;
    throw const ForecastNotConfigured();
  }

  @override
  Future<double?> seaTemp(RuleRegion region, DateTime date) {
    calls++;
    throw const ForecastNotConfigured();
  }
}
