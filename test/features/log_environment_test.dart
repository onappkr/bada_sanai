import 'dart:async';
import 'dart:convert';

import 'package:bada_sanai/features/catch_log/domain/log_environment.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_models.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_ports.dart';
import 'package:bada_sanai/features/forecast/domain/forecast_service.dart';
import 'package:bada_sanai/features/species/domain/rule_book.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:bada_sanai/features/tracking/domain/tracking_ports.dart';
import 'package:test/test.dart';

// 시험용 가짜 값이다(실제 예보가 아니다).
final ruleBook = RuleBook.parse(
  speciesRuleJson: jsonEncode({'version': 1, 'species': [], 'rules': []}),
  regionJson: jsonEncode({
    'version': 1,
    'regions': [
      {'code': 'R-1', 'name_ko': '가해역', 'center': {'lat': 35.0, 'lng': 129.0}},
    ],
  }),
);

final t0 = DateTime.utc(2026, 11, 27, 6);

class FixedSource implements LocationSource {
  FixedSource.fix(double lat, double lng) : _stream = Stream.value(LocationSample(lat: lat, lng: lng, time: DateTime.utc(2026, 11, 27, 6), accuracyM: 10));
  FixedSource.error(Object e) : _stream = Stream.error(e);
  FixedSource.silent() : _stream = const Stream.empty();

  final Stream<LocationSample> _stream;

  @override
  Stream<LocationSample> watch() => _stream;
}

class OkForecastSource implements ForecastSource {
  @override
  Future<TideInfo?> tide(RuleRegion region, DateTime date) async => const TideInfo(mulddae: 9);

  @override
  Future<WeatherInfo?> weather(RuleRegion region, DateTime date) async => const WeatherInfo(tempC: 11);

  @override
  Future<double?> seaTemp(RuleRegion region, DateTime date) async => 16.4;
}

class MemCache implements ForecastCacheStore {
  final map = <String, CachedEntry>{};

  @override
  Future<CachedEntry?> get(String key) async => map[key];

  @override
  Future<void> put(String key, CachedEntry entry) async => map[key] = entry;
}

Future<ForecastService> serviceWith(ForecastSource source) async => ForecastService(
      source: source,
      cache: MemCache(),
      ruleBook: ruleBook,
      clock: () => t0,
    );

void main() {
  group('shouldAttachEnvironment: 지금 값을 붙여도 되는 일지인가', () {
    final now = DateTime(2026, 11, 27, 12);

    test('방금·몇 시간 안의 일지는 붙인다', () {
      expect(shouldAttachEnvironment(now, now), isTrue);
      expect(shouldAttachEnvironment(now.subtract(const Duration(hours: 2)), now), isTrue);
      expect(shouldAttachEnvironment(now.subtract(const Duration(hours: 3)), now), isTrue);
    });

    test('3시간을 넘긴 과거나 미래 일지는 붙이지 않는다(틀린 정보가 되므로)', () {
      expect(shouldAttachEnvironment(now.subtract(const Duration(hours: 3, minutes: 1)), now), isFalse);
      expect(shouldAttachEnvironment(now.subtract(const Duration(days: 2)), now), isFalse);
      expect(shouldAttachEnvironment(now.add(const Duration(hours: 5)), now), isFalse);
    });

    test('기준 시간은 바꿀 수 있다', () {
      expect(
        shouldAttachEnvironment(now.subtract(const Duration(hours: 5)), now, window: const Duration(hours: 6)),
        isTrue,
      );
    });
  });

  group('captureEnvironment', () {
    test('위치와 예보를 모두 얻으면 둘 다 붙는다', () async {
      final env = await captureEnvironment(
        source: FixedSource.fix(35.01, 129.01),
        forecastService: () => serviceWith(OkForecastSource()),
        clock: () => t0,
      );
      expect(env!.lat, 35.01);
      expect(env.lng, 129.01);
      expect(env.forecast!.regionCode, 'R-1');
      expect(env.forecast!.tide!.mulddae, 9);
      expect(env.forecast!.seaTempC, 16.4);
      expect(env.isEmpty, isFalse);
    });

    test('예보를 못 얻으면(연결 전) 위치만 붙는다', () async {
      final env = await captureEnvironment(
        source: FixedSource.fix(35.01, 129.01),
        forecastService: () => serviceWith(const NoForecastSource()),
        clock: () => t0,
      );
      expect(env!.lat, 35.01);
      expect(env.forecast, isNull);
    });

    test('해역이 없는 바다면 위치만 붙는다', () async {
      final env = await captureEnvironment(
        source: FixedSource.fix(33.0, 126.0),
        forecastService: () => serviceWith(OkForecastSource()),
        clock: () => t0,
      );
      expect(env!.lat, 33.0);
      expect(env.forecast, isNull);
    });

    test('예보 서비스를 만들다 실패해도 위치는 붙고 예외는 없다', () async {
      final env = await captureEnvironment(
        source: FixedSource.fix(35.01, 129.01),
        forecastService: () async => throw StateError('규칙 데이터 오류'),
        clock: () => t0,
      );
      expect(env!.lat, 35.01);
      expect(env.forecast, isNull);
    });

    test('위치를 못 얻으면(권한 없음) 아무것도 붙지 않고 예외도 없다', () async {
      final env = await captureEnvironment(
        source: FixedSource.error(StateError('위치 권한이 필요해요')),
        forecastService: () => serviceWith(OkForecastSource()),
        clock: () => t0,
      );
      expect(env, isNull);
    });

    test('위치가 시간 안에 안 오면 아무것도 붙지 않는다', () async {
      final env = await captureEnvironment(
        source: FixedSource.silent(),
        forecastService: () => serviceWith(OkForecastSource()),
        clock: () => t0,
        locationTimeout: const Duration(milliseconds: 50),
      );
      expect(env, isNull);
    });
  });

  group('LogEnvironment 저장 형식', () {
    test('예보를 JSON으로 저장하고 다시 읽는다(위치는 열에서)', () async {
      final env = (await captureEnvironment(
        source: FixedSource.fix(35.01, 129.01),
        forecastService: () => serviceWith(OkForecastSource()),
        clock: () => t0,
      ))!;
      final back = LogEnvironment.fromColumns(lat: env.lat, lng: env.lng, envJson: env.toEnvJson());
      expect(back.lat, 35.01);
      expect(back.forecast!.tide!.mulddae, 9);
      expect(back.forecast!.weather!.tempC, 11);
    });

    test('예보가 없으면 빈 JSON 객체', () {
      expect(const LogEnvironment(lat: 1, lng: 2).toEnvJson(), '{}');
    });

    test('env가 손상돼도 위치는 살린다', () {
      final back = LogEnvironment.fromColumns(lat: 35, lng: 129, envJson: '{깨짐');
      expect(back.lat, 35);
      expect(back.forecast, isNull);
    });

    test('옛 데이터(env = {})는 빈 환경이 된다', () {
      expect(LogEnvironment.fromColumns(envJson: '{}').isEmpty, isTrue);
    });
  });
}
