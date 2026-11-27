import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../../species/application/species_providers.dart';
import '../data/forecast_caches.dart';
import '../domain/forecast_ports.dart';
import '../domain/forecast_service.dart';

/// 예보 원천. 공공 API 어댑터가 만들어지면 여기서 바꿔 끼운다(지금은 연결 전).
final forecastSourceProvider = Provider<ForecastSource>((ref) => const NoForecastSource());

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
