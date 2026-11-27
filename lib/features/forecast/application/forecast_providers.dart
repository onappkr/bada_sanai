import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../../species/application/species_providers.dart';
import '../data/forecast_caches.dart';
import '../data/kma_forecast_source.dart';
import '../domain/forecast_ports.dart';
import '../domain/forecast_service.dart';

/// 예보 원천. 기상청 서비스 키(`--dart-define=KMA_SERVICE_KEY`)가 있으면 단기예보 어댑터를 쓰고,
/// 없으면 "연동 준비 중"으로 보인다. 물때·수온 원천은 아직 없다(값 없음).
final forecastSourceProvider = Provider<ForecastSource>(
  (ref) => kmaServiceKey.isEmpty ? const NoForecastSource() : KmaForecastSource(serviceKey: kmaServiceKey),
);

final forecastCacheProvider = Provider<ForecastCacheStore>(
  (ref) => DriftForecastCache(ref.watch(databaseProvider)),
);

/// 해역 데이터(RuleBook)를 읽은 뒤 만들어지는 예보 서비스.
final forecastServiceProvider = FutureProvider<ForecastService>((ref) async {
  final book = await ref.watch(ruleBookProvider.future);
  return ForecastService(
    source: ref.watch(forecastSourceProvider),
    cache: ref.watch(forecastCacheProvider),
    ruleBook: book,
  );
});
