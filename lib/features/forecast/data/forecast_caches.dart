import '../../../core/db/app_database.dart';
import '../domain/forecast_ports.dart';

/// Drift(forecast_cache 테이블) 기반 예보 캐시.
class DriftForecastCache implements ForecastCacheStore {
  DriftForecastCache(this._db);

  final AppDatabase _db;

  @override
  Future<CachedEntry?> get(String key) async {
    final row = await (_db.select(_db.forecastCache)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    return CachedEntry(
      payload: row.payload,
      fetchedAt: row.fetchedAt,
      expiresAt: row.expiresAt,
    );
  }

  @override
  Future<void> put(String key, CachedEntry entry) =>
      _db.into(_db.forecastCache).insertOnConflictUpdate(ForecastCacheCompanion.insert(
            key: key,
            payload: entry.payload,
            fetchedAt: entry.fetchedAt.toUtc(),
            expiresAt: entry.expiresAt.toUtc(),
          ));
}

/// 메모리 캐시. 미리보기·테스트용.
class InMemoryForecastCache implements ForecastCacheStore {
  final Map<String, CachedEntry> _map = {};

  @override
  Future<CachedEntry?> get(String key) async => _map[key];

  @override
  Future<void> put(String key, CachedEntry entry) async => _map[key] = entry;
}
