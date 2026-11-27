import 'dart:convert';

import 'forecast_models.dart';

/// 기상청 단기예보(`getVilageFcst`) JSON 응답을 [WeatherInfo]로 바꾼다. 순수 Dart.
///
/// 응답 구조(공공데이터포털 "기상청_단기예보 ((구)_동네예보) 조회서비스" 문서 기준):
/// `response.header.resultCode`("00"이 정상), `response.body.items.item[]`에
/// `{fcstDate, fcstTime, category, fcstValue}`가 항목별로 한 줄씩 들어 있다.
/// 실제 서비스 키로 응답을 확인하지 못했으므로 문서와 다르면 이 파일만 고치면 된다.
class KmaApiError implements Exception {
  const KmaApiError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'KmaApiError($code: $message)';
}

class KmaWeatherParser {
  const KmaWeatherParser._();

  /// [targetDate]는 `20261127` 형식, [referenceHour]는 0~23(그 날 가장 가까운 예보 시각을 쓴다).
  /// 해당 날짜의 예보가 없으면 null. 서비스가 오류 코드를 주면 [KmaApiError], 모양이 이상하면 [FormatException].
  static WeatherInfo? parse(String body, {required String targetDate, required int referenceHour}) {
    final Object? root;
    try {
      root = jsonDecode(body);
    } on FormatException {
      // 인증 오류 등은 JSON이 아니라 XML로 오기도 한다.
      throw FormatException('기상청 응답이 JSON이 아닙니다: ${_snippet(body)}');
    }
    final response = root is Map ? root['response'] : null;
    if (response is! Map) throw const FormatException('기상청 응답 형식이 올바르지 않습니다');
    final header = response['header'];
    final code = header is Map ? '${header['resultCode']}' : '';
    if (code != '00') {
      final msg = header is Map ? '${header['resultMsg']}' : '';
      // 03: 데이터 없음(해당 날짜 예보가 아직 없다) — 오류가 아니라 값 없음이다.
      if (code == '03') return null;
      throw KmaApiError(code, msg);
    }
    final items = _items(response['body']);
    if (items.isEmpty) return null;

    // 시각별로 모은 뒤 기준 시각에 가장 가까운 하나를 쓴다.
    final byTime = <String, Map<String, String>>{};
    for (final it in items) {
      if (it is! Map || '${it['fcstDate']}' != targetDate) continue;
      byTime.putIfAbsent('${it['fcstTime']}', () => {})['${it['category']}'] = '${it['fcstValue']}';
    }
    if (byTime.isEmpty) return null;

    String? best;
    var bestGap = 1 << 30;
    for (final t in byTime.keys) {
      final h = int.tryParse(t.padLeft(4, '0').substring(0, 2));
      if (h == null) continue;
      final gap = (h - referenceHour).abs();
      if (gap < bestGap) {
        bestGap = gap;
        best = t;
      }
    }
    if (best == null) return null;
    final v = byTime[best]!;

    final pty = int.tryParse(v['PTY'] ?? '') ?? 0;
    final sky = int.tryParse(v['SKY'] ?? '');
    return WeatherInfo(
      tempC: double.tryParse(v['TMP'] ?? ''),
      windDirDeg: double.tryParse(v['VEC'] ?? '')?.round(),
      windMps: double.tryParse(v['WSD'] ?? ''),
      waveM: double.tryParse(v['WAV'] ?? ''),
      sky: skyCode(sky: sky, pty: pty),
      precipMm: _precip(v['PCP']),
    );
  }

  /// 강수 형태가 있으면 그것이 우선이고, 없으면 하늘 상태(1 맑음, 3 구름많음, 4 흐림).
  static String? skyCode({int? sky, int pty = 0}) {
    if (pty != 0) {
      return switch (pty) {
        3 || 7 => 'snow',
        _ => 'rain', // 1 비, 2 비/눈, 4 소나기, 5 빗방울, 6 빗방울눈날림
      };
    }
    return switch (sky) {
      1 => 'clear',
      3 => 'cloudy',
      4 => 'overcast',
      _ => null,
    };
  }

  /// "강수없음", "1.0mm", "30.0~50.0mm", "1.0mm 미만", "50.0mm 이상" 형태를 숫자(mm)로.
  static double? _precip(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.contains('없음')) return 0;
    final m = RegExp(r'\d+(\.\d+)?').firstMatch(raw);
    return m == null ? null : double.parse(m.group(0)!);
  }

  static List<dynamic> _items(Object? body) {
    if (body is! Map) return const [];
    final items = body['items'];
    if (items is! Map) return const [];
    final item = items['item'];
    return item is List ? item : const [];
  }

  static String _snippet(String s) => s.length <= 80 ? s : '${s.substring(0, 80)}…';
}

/// 단기예보를 요청할 때 쓰는 가장 최근 발표 시각(02·05·08·11·14·17·20·23시 발표, 약 10분 뒤부터 조회 가능).
/// 반환: (`20261127`, `1400`). 입력은 한국 시각(KST)으로 본다.
({String baseDate, String baseTime}) kmaBaseTime(DateTime kst) {
  const hours = [2, 5, 8, 11, 14, 17, 20, 23];
  // 발표 후 10분이 지나야 조회되므로 10분 전 시각을 기준으로 찾는다.
  final t = kst.subtract(const Duration(minutes: 10));
  DateTime base;
  final candidates = hours.where((h) => h <= t.hour).toList();
  if (candidates.isEmpty) {
    final prev = DateTime(t.year, t.month, t.day).subtract(const Duration(days: 1));
    base = DateTime(prev.year, prev.month, prev.day, 23);
  } else {
    base = DateTime(t.year, t.month, t.day, candidates.last);
  }
  String two(int n) => n.toString().padLeft(2, '0');
  return (
    baseDate: '${base.year}${two(base.month)}${two(base.day)}',
    baseTime: '${two(base.hour)}00',
  );
}
