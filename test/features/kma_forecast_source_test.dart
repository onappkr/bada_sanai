import 'dart:convert';
import 'dart:io';

import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/features/forecast/data/kma_forecast_source.dart';
import 'package:bada_sanai/features/species/domain/rule_book.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  final body = File('test/fixtures/kma_vilage_fcst.json').readAsStringSync();
  // 2026-11-27 11:30 KST = 02:30 UTC → 11시 발표분을 요청해야 한다.
  final now = DateTime.utc(2026, 11, 27, 2, 30);
  const region = RuleRegion(
      code: 'S-1', nameKo: '시험', center: GeoPoint(35, 129), gridNx: 98, gridNy: 76);

  test('요청에 격자·발표 시각·키가 들어가고 응답을 해석한다', () async {
    late Uri seen;
    final src = KmaForecastSource(
      serviceKey: 'KEY',
      clock: () => now,
      client: MockClient((req) async {
        seen = req.url;
        return http.Response.bytes(utf8.encode(body), 200);
      }),
    );
    final w = await src.weather(region, DateTime(2026, 11, 27, 12));
    expect(seen.queryParameters['nx'], '98');
    expect(seen.queryParameters['ny'], '76');
    expect(seen.queryParameters['base_date'], '20261127');
    expect(seen.queryParameters['base_time'], '1100');
    expect(seen.queryParameters['serviceKey'], 'KEY');
    expect(seen.queryParameters['dataType'], 'JSON');
    expect(w!.tempC, 9);
  });

  test('격자 좌표가 없는 해역은 호출하지 않고 null', () async {
    var calls = 0;
    final src = KmaForecastSource(
      serviceKey: 'KEY',
      client: MockClient((req) async {
        calls++;
        return http.Response.bytes(utf8.encode(body), 200);
      }),
    );
    const noGrid = RuleRegion(code: 'S-2', nameKo: '격자 없음', center: GeoPoint(35, 129));
    expect(await src.weather(noGrid, DateTime(2026, 11, 27)), isNull);
    expect(calls, 0);
  });

  test('HTTP 오류는 예외로 올려 서비스가 재시도·캐시 대체를 하게 한다', () async {
    final src = KmaForecastSource(
      serviceKey: 'KEY',
      clock: () => now,
      client: MockClient((req) async => http.Response('oops', 500)),
    );
    await expectLater(src.weather(region, DateTime(2026, 11, 27)), throwsA(isA<http.ClientException>()));
  });

  test('날짜만 준 경우(자정)는 낮 12시 예보를 쓴다', () async {
    final src = KmaForecastSource(
      serviceKey: 'KEY',
      clock: () => now,
      client: MockClient((req) async => http.Response.bytes(utf8.encode(body), 200)),
    );
    expect((await src.weather(region, DateTime(2026, 11, 27)))!.tempC, 9);
  });

  test('조석·수온은 아직 원천이 없어 null', () async {
    final src = KmaForecastSource(serviceKey: 'KEY', client: MockClient((r) async => http.Response('', 200)));
    expect(await src.tide(region, DateTime(2026, 11, 27)), isNull);
    expect(await src.seaTemp(region, DateTime(2026, 11, 27)), isNull);
  });
}
