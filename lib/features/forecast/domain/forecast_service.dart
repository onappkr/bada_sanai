import 'dart:async';
import 'dart:convert';

import '../../../core/geo/geo_point.dart';
import '../../species/domain/rule_book.dart';
import 'forecast_models.dart';
import 'forecast_ports.dart';

/// 캐시·호출 정책의 초기값(설계 문서 5장). 운영하면서 조정한다.
abstract final class ForecastPolicy {
  static const weatherTtl = Duration(hours: 3);
  static const tideTtl = Duration(hours: 24);
  static const seaTempTtl = Duration(hours: 6);

  /// 호출 한 번의 제한 시간. 실패하면 한 번 더 시도한다.
  static const requestTimeout = Duration(seconds: 8);

  /// 위치와 해역 중심이 이보다 멀면 지원하지 않는 해역으로 본다.
  static const maxRegionDistanceM = 50000.0;
}

/// 현재 위치와 날짜의 예보를 돌려준다.
///
/// 1. 가장 가까운 해역을 정한다(50km보다 멀면 [ForecastErrorKind.unsupportedRegion]).
/// 2. 물때·날씨·수온을 각각 캐시에서 찾아 유효하면 쓴다.
/// 3. 만료됐으면 원천을 호출한다(제한 시간 8초, 실패하면 1회 재시도) → 성공하면 캐시에 저장.
/// 4. 호출이 실패하면 만료된 캐시를 쓰고 `stale`로 표시한다. 캐시도 없으면 그 항목만 비운다.
/// 5. 세 항목이 모두 비면 오류를 던진다(원천이 연결 전이면 [ForecastErrorKind.notConfigured]).
class ForecastService {
  ForecastService({
    required this.source,
    required this.cache,
    required this.ruleBook,
    DateTime Function()? clock,
    this.requestTimeout = ForecastPolicy.requestTimeout,
  }) : _clock = clock ?? DateTime.now;

  final ForecastSource source;
  final ForecastCacheStore cache;
  final RuleBook ruleBook;
  final DateTime Function() _clock;

  /// 호출 한 번의 제한 시간(시험에서는 짧게 줄인다).
  final Duration requestTimeout;

  Future<ForecastBundle> get(GeoPoint position, DateTime date) async {
    final region = ruleBook.nearestRegion(
      position,
      maxDistanceM: ForecastPolicy.maxRegionDistanceM,
    );
    if (region == null) throw const ForecastError(ForecastErrorKind.unsupportedRegion);

    final day = forecastDateKey(date);
    final results = await Future.wait([
      _load<TideInfo>(
        key: '${region.code}|$day|tide',
        ttl: ForecastPolicy.tideTtl,
        fetch: () => source.tide(region, date),
        encode: (v) => jsonEncode(v.toJson()),
        decode: (s) => TideInfo.fromJson(jsonDecode(s) as Map<String, dynamic>),
      ),
      _load<WeatherInfo>(
        key: '${region.code}|$day|weather',
        ttl: ForecastPolicy.weatherTtl,
        fetch: () => source.weather(region, date),
        encode: (v) => jsonEncode(v.toJson()),
        decode: (s) => WeatherInfo.fromJson(jsonDecode(s) as Map<String, dynamic>),
      ),
      _load<double>(
        key: '${region.code}|$day|seatemp',
        ttl: ForecastPolicy.seaTempTtl,
        fetch: () => source.seaTemp(region, date),
        encode: (v) => jsonEncode({'sea_temp_c': v}),
        decode: (s) => ((jsonDecode(s) as Map<String, dynamic>)['sea_temp_c'] as num).toDouble(),
      ),
    ]);
    final tide = results[0] as _Part<TideInfo>;
    final weather = results[1] as _Part<WeatherInfo>;
    final sea = results[2] as _Part<double>;

    final parts = [tide, weather, sea];
    final used = parts.where((p) => p.value != null).toList();
    if (used.isEmpty) {
      final allNotConfigured = parts.every((p) => p.notConfigured);
      throw ForecastError(
        allNotConfigured ? ForecastErrorKind.notConfigured : ForecastErrorKind.unavailable,
      );
    }

    // 쓰인 값 중 가장 오래된 갱신 시각을 "마지막 갱신 시각"으로 보여 준다.
    final oldest = used.map((p) => p.fetchedAt!).reduce((a, b) => a.isBefore(b) ? a : b);
    return ForecastBundle(
      regionCode: region.code,
      date: day,
      fetchedAt: oldest.toUtc(),
      stale: used.any((p) => p.stale),
      tide: tide.value,
      weather: weather.value,
      seaTempC: sea.value,
    );
  }

  Future<_Part<T>> _load<T extends Object>({
    required String key,
    required Duration ttl,
    required Future<T?> Function() fetch,
    required String Function(T) encode,
    required T Function(String) decode,
  }) async {
    final now = _clock();
    T? cachedValue;
    CachedEntry? entry;
    try {
      entry = await cache.get(key);
      if (entry != null) cachedValue = decode(entry.payload);
    } catch (_) {
      // 손상된 캐시는 없는 것으로 본다.
      entry = null;
      cachedValue = null;
    }

    if (entry != null && cachedValue != null && now.isBefore(entry.expiresAt)) {
      return _Part(value: cachedValue, fetchedAt: entry.fetchedAt, stale: false);
    }

    try {
      final fresh = await _fetchWithRetry(fetch);
      if (fresh == null) {
        // 원천이 "이 항목은 값이 없다"고 답했다: 오래된 캐시가 있어도 지금 값이 아니므로 쓰지 않는다.
        return _Part<T>();
      }
      try {
        await cache.put(
          key,
          CachedEntry(payload: encode(fresh), fetchedAt: now, expiresAt: now.add(ttl)),
        );
      } catch (_) {
        // 캐시 저장 실패는 값을 쓰는 데 지장이 없다.
      }
      return _Part(value: fresh, fetchedAt: now, stale: false);
    } on ForecastNotConfigured {
      return _fallback(entry, cachedValue, notConfigured: true);
    } catch (_) {
      return _fallback(entry, cachedValue);
    }
  }

  _Part<T> _fallback<T extends Object>(CachedEntry? entry, T? cached, {bool notConfigured = false}) {
    if (entry != null && cached != null) {
      return _Part(value: cached, fetchedAt: entry.fetchedAt, stale: true);
    }
    return _Part<T>(notConfigured: notConfigured);
  }

  Future<T?> _fetchWithRetry<T>(Future<T?> Function() fetch) async {
    try {
      return await fetch().timeout(requestTimeout);
    } on ForecastNotConfigured {
      rethrow; // 연결 전이면 다시 해도 같다
    } catch (_) {
      return fetch().timeout(requestTimeout);
    }
  }
}

class _Part<T> {
  const _Part({this.value, this.fetchedAt, this.stale = false, this.notConfigured = false});

  final T? value;
  final DateTime? fetchedAt;
  final bool stale;
  final bool notConfigured;
}
