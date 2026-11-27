import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../species/domain/rule_book.dart';
import '../domain/forecast_models.dart';
import '../domain/forecast_ports.dart';
import '../domain/kma_weather_parser.dart';

/// 기상청 단기예보(공공데이터포털 `VilageFcstInfoService_2.0/getVilageFcst`)로 날씨를 가져오는 어댑터.
///
/// **실제 서비스 키로 호출해 확인하지 못했다.** 응답 해석은 문서 기준이며(`kma_weather_parser.dart`),
/// 키 발급·승인과 실제 응답 확인은 사람이 해야 한다. 물때(조석)와 수온은 원천이 정해지지 않아
/// 아직 값을 주지 않는다(null → 화면에 "정보 없음").
///
/// 키는 코드에 넣지 않고 빌드 때 `--dart-define=KMA_SERVICE_KEY=...`로 넘긴다.
class KmaForecastSource implements ForecastSource {
  KmaForecastSource({
    required this.serviceKey,
    http.Client? client,
    DateTime Function()? clock,
    this.baseUrl = 'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0',
  }) : _client = client ?? http.Client(),
       _clock = clock ?? DateTime.now;

  final String serviceKey;
  final String baseUrl;
  final http.Client _client;
  final DateTime Function() _clock;

  @override
  Future<TideInfo?> tide(RuleRegion region, DateTime date) async => null;

  @override
  Future<double?> seaTemp(RuleRegion region, DateTime date) async => null;

  @override
  Future<WeatherInfo?> weather(RuleRegion region, DateTime date) async {
    final nx = region.gridNx, ny = region.gridNy;
    if (nx == null || ny == null) return null; // 이 해역에 격자 좌표가 없다

    final kstNow = _clock().toUtc().add(const Duration(hours: 9));
    final base = kmaBaseTime(kstNow);
    final uri = Uri.parse('$baseUrl/getVilageFcst').replace(
      queryParameters: {
        'serviceKey': serviceKey,
        'pageNo': '1',
        'numOfRows': '1000',
        'dataType': 'JSON',
        'base_date': base.baseDate,
        'base_time': base.baseTime,
        'nx': '$nx',
        'ny': '$ny',
      },
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw http.ClientException('기상청 응답 ${res.statusCode}', uri);
    }

    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    final target = '${local.year}${two(local.month)}${two(local.day)}';
    // 시각이 자정(날짜만 준 경우)이면 낮 12시 예보를 쓴다.
    final hour = (local.hour == 0 && local.minute == 0) ? 12 : local.hour;
    return KmaWeatherParser.parse(
      // 서버가 문자 집합을 알리지 않아도 한글이 깨지지 않게 직접 UTF-8로 읽는다.
      utf8.decode(res.bodyBytes, allowMalformed: true),
      targetDate: target,
      referenceHour: hour,
    );
  }
}
