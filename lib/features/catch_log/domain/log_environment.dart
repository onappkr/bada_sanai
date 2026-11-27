import 'dart:async';
import 'dart:convert';

import '../../../core/geo/geo_point.dart';
import '../../forecast/domain/forecast_models.dart';
import '../../forecast/domain/forecast_service.dart';
import '../../tracking/domain/current_location.dart';
import '../../tracking/domain/track_logic.dart' show LocationSample;
import '../../tracking/domain/tracking_ports.dart';

/// 일지를 쓸 때 자동으로 붙는 환경(위치, 물때·날씨·수온). 값을 얻지 못한 항목은 비어 있다.
class LogEnvironment {
  const LogEnvironment({this.lat, this.lng, this.forecast});

  final double? lat;
  final double? lng;
  final ForecastBundle? forecast;

  bool get isEmpty => lat == null && lng == null && forecast == null;

  /// DB의 `env` 열에 넣는 JSON. 위치는 별도 열(lat, lng)에 저장하므로 예보만 담는다.
  String toEnvJson() => jsonEncode({if (forecast != null) 'forecast': forecast!.toJson()});

  /// DB의 열 값으로 되살린다. `env`가 손상됐으면 예보만 비우고 위치는 살린다.
  factory LogEnvironment.fromColumns({double? lat, double? lng, required String envJson}) {
    ForecastBundle? forecast;
    try {
      final m = jsonDecode(envJson);
      if (m is Map<String, dynamic> && m['forecast'] is Map<String, dynamic>) {
        forecast = ForecastBundle.fromJson(m['forecast'] as Map<String, dynamic>);
      }
    } catch (_) {
      forecast = null;
    }
    return LogEnvironment(lat: lat, lng: lng, forecast: forecast);
  }
}

/// 지금의 환경을 일지에 붙여도 되는지.
///
/// 환경은 "지금" 값이라서, 며칠 전 일지를 나중에 적으면서 오늘 날씨를 붙이면 틀린 정보가 된다.
/// 낚시한 시각이 지금과 [window] 이내일 때만 붙인다.
bool shouldAttachEnvironment(DateTime fishedAt, DateTime now, {Duration window = const Duration(hours: 3)}) {
  return fishedAt.difference(now).abs() <= window;
}

/// 현재 위치와 예보를 모아 [LogEnvironment]를 만든다. 절대 예외를 던지지 않는다.
///
/// - 위치를 얻지 못하면(권한 없음·위치 꺼짐·시간 초과) 아무것도 붙이지 않고 null을 돌려준다.
/// - 위치는 얻었는데 예보를 못 얻으면(해역 없음·연결 전·오프라인) 위치만 붙인다.
/// - 위치는 권한 창을 띄우지 않는 [source]로만 얻는다(저장하다가 갑자기 권한 창이 뜨지 않게).
Future<LogEnvironment?> captureEnvironment({
  required LocationSource source,
  required Future<ForecastService> Function() forecastService,
  DateTime Function()? clock,
  Duration locationTimeout = const Duration(seconds: 4),
}) async {
  final now = (clock ?? DateTime.now)();
  final LocationSample fix;
  try {
    fix = await currentLocation(source, timeout: locationTimeout);
  } catch (_) {
    return null;
  }

  ForecastBundle? forecast;
  try {
    final service = await forecastService();
    forecast = await service.get(GeoPoint(fix.lat, fix.lng), now);
  } catch (_) {
    forecast = null;
  }
  return LogEnvironment(lat: fix.lat, lng: fix.lng, forecast: forecast);
}
