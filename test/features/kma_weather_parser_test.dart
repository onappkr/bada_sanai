import 'dart:io';

import 'package:bada_sanai/features/forecast/domain/kma_weather_parser.dart';
import 'package:test/test.dart';

/// 기상청 단기예보 응답 해석. fixture는 문서의 응답 형식을 따라 손으로 만든 것이며
/// 실제 서비스 응답으로 확인한 것이 아니다.
void main() {
  final body = File('test/fixtures/kma_vilage_fcst.json').readAsStringSync();

  test('기준 시각에 가장 가까운 예보를 고른다', () {
    final noon = KmaWeatherParser.parse(body, targetDate: '20261127', referenceHour: 12)!;
    expect(noon.tempC, 9);
    expect(noon.windDirDeg, 315);
    expect(noon.windMps, 4.2);
    expect(noon.waveM, 0.5);
    expect(noon.sky, 'cloudy');
    expect(noon.precipMm, 0);

    final evening = KmaWeatherParser.parse(body, targetDate: '20261127', referenceHour: 17)!;
    expect(evening.tempC, 6);
    expect(evening.sky, 'rain'); // 강수 형태가 하늘 상태보다 우선
    expect(evening.precipMm, 1.0);
    expect(evening.windMps, isNull); // 그 시각에 없는 항목은 null
  });

  test('다른 날짜의 예보는 섞이지 않는다', () {
    final next = KmaWeatherParser.parse(body, targetDate: '20261128', referenceHour: 12)!;
    expect(next.tempC, 3);
    expect(KmaWeatherParser.parse(body, targetDate: '20261201', referenceHour: 12), isNull);
  });

  test('하늘 상태·강수 형태 코드', () {
    expect(KmaWeatherParser.skyCode(sky: 1), 'clear');
    expect(KmaWeatherParser.skyCode(sky: 4), 'overcast');
    expect(KmaWeatherParser.skyCode(sky: 1, pty: 3), 'snow');
    expect(KmaWeatherParser.skyCode(sky: 1, pty: 4), 'rain');
    expect(KmaWeatherParser.skyCode(sky: 9), isNull);
  });

  test('오류 코드는 KmaApiError, 데이터 없음(03)은 null', () {
    String err(String code) =>
        '{"response":{"header":{"resultCode":"$code","resultMsg":"x"}}}';
    expect(() => KmaWeatherParser.parse(err('30'), targetDate: '20261127', referenceHour: 12),
        throwsA(isA<KmaApiError>()));
    expect(KmaWeatherParser.parse(err('03'), targetDate: '20261127', referenceHour: 12), isNull);
  });

  test('JSON이 아니거나 모양이 이상하면 FormatException', () {
    expect(() => KmaWeatherParser.parse('<OpenAPI_ServiceResponse/>', targetDate: 'x', referenceHour: 12),
        throwsFormatException);
    expect(() => KmaWeatherParser.parse('[]', targetDate: 'x', referenceHour: 12), throwsFormatException);
  });

  group('발표 시각(kmaBaseTime)', () {
    ({String baseDate, String baseTime}) at(int y, int m, int d, int h, int min) =>
        kmaBaseTime(DateTime(y, m, d, h, min));

    test('발표 10분 뒤부터 새 발표를 쓴다', () {
      expect(at(2026, 11, 27, 14, 5).baseTime, '1100'); // 14시 발표는 14:10부터
      expect(at(2026, 11, 27, 14, 10).baseTime, '1400');
      expect(at(2026, 11, 27, 16, 59).baseTime, '1400');
    });

    test('자정~02:10은 전날 23시 발표', () {
      final b = at(2026, 11, 27, 1, 30);
      expect(b.baseDate, '20261126');
      expect(b.baseTime, '2300');
    });

    test('월 경계', () {
      expect(at(2026, 12, 1, 0, 5).baseDate, '20261130');
    });
  });
}
