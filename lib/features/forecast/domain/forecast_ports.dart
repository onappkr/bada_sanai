import '../../species/domain/rule_book.dart';
import 'forecast_models.dart';

/// 예보를 가져오지 못했을 때의 종류. 화면은 종류별로 안내 문구를 고른다.
enum ForecastErrorKind {
  /// 가까운 해역이 없다(데이터가 없는 바다).
  unsupportedRegion,

  /// 예보 원천(공공 API)이 아직 연결되지 않았다.
  notConfigured,

  /// 원천 호출이 실패했고 쓸 수 있는 캐시도 없다.
  unavailable,
}

class ForecastError implements Exception {
  const ForecastError(this.kind);

  final ForecastErrorKind kind;

  String get message => switch (kind) {
        ForecastErrorKind.unsupportedRegion => '이 위치 근처는 물때·날씨 정보를 지원하지 않아요.',
        ForecastErrorKind.notConfigured => '물때·날씨 연동을 준비하고 있어요.',
        ForecastErrorKind.unavailable => '물때·날씨를 가져오지 못했어요. 잠시 뒤 다시 시도해 주세요.',
      };

  @override
  String toString() => 'ForecastError(${kind.name})';
}

/// 원천이 아직 연결되지 않았음을 알리는 예외(재시도하지 않는다).
class ForecastNotConfigured implements Exception {
  const ForecastNotConfigured();
}

/// 예보 원천. 실제 구현은 공공 API(기상청·해양조사원 등) 어댑터이며 API 키가 필요하다.
/// 값이 없으면 null을 돌려주고, 호출이 실패하면 예외를 던진다.
abstract interface class ForecastSource {
  Future<TideInfo?> tide(RuleRegion region, DateTime date);

  Future<WeatherInfo?> weather(RuleRegion region, DateTime date);

  Future<double?> seaTemp(RuleRegion region, DateTime date);
}

/// 원천이 연결되기 전의 기본값. 모든 호출이 [ForecastNotConfigured]를 던진다.
class NoForecastSource implements ForecastSource {
  const NoForecastSource();

  @override
  Future<TideInfo?> tide(RuleRegion region, DateTime date) => throw const ForecastNotConfigured();

  @override
  Future<WeatherInfo?> weather(RuleRegion region, DateTime date) =>
      throw const ForecastNotConfigured();

  @override
  Future<double?> seaTemp(RuleRegion region, DateTime date) => throw const ForecastNotConfigured();
}

/// 캐시에 저장된 한 건.
class CachedEntry {
  const CachedEntry({required this.payload, required this.fetchedAt, required this.expiresAt});

  final String payload;
  final DateTime fetchedAt;
  final DateTime expiresAt;
}

/// 예보 캐시 저장소. 키는 `해역코드|날짜|종류`.
abstract interface class ForecastCacheStore {
  Future<CachedEntry?> get(String key);

  Future<void> put(String key, CachedEntry entry);
}
