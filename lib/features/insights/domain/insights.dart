import '../../catch_log/domain/catch_log_models.dart';
import '../../species/domain/species_stats.dart' show isWithinMonths;

/// 내 일지만으로 계산하는 분석·추천. 순수 Dart.
///
/// 외부 자료(다른 사람의 기록, 해역 통계)를 쓰지 않는다. 표본이 작을수록 우연의 영향이 커서
/// 모든 결과에 출조 횟수를 같이 돌려주고, 믿을 만한 수준([minReliableTrips])이 아니면 `reliable`이 false다.
const minReliableTrips = 3;

/// 추천을 내려면 필요한 최소 기록(출조) 수.
const minLogsForRecommendation = 5;

enum TimeBand { dawn, morning, afternoon, evening, night }

extension TimeBandLabel on TimeBand {
  String get label => switch (this) {
        TimeBand.dawn => '새벽(4~8시)',
        TimeBand.morning => '오전(8~12시)',
        TimeBand.afternoon => '오후(12~17시)',
        TimeBand.evening => '저녁(17~21시)',
        TimeBand.night => '밤(21~4시)',
      };
}

TimeBand timeBandOf(DateTime t) {
  final h = t.toLocal().hour;
  if (h >= 4 && h < 8) return TimeBand.dawn;
  if (h >= 8 && h < 12) return TimeBand.morning;
  if (h >= 12 && h < 17) return TimeBand.afternoon;
  if (h >= 17 && h < 21) return TimeBand.evening;
  return TimeBand.night;
}

/// 한 묶음(포인트·시간대·달·조건)의 성적.
class GroupStat<K> {
  const GroupStat({required this.key, required this.trips, required this.fish, required this.zeroTrips});

  final K key;

  /// 출조(일지) 수.
  final int trips;

  /// 잡은 마릿수 합계.
  final int fish;

  /// 한 마리도 못 잡은 출조 수(꽝).
  final int zeroTrips;

  double get perTrip => trips == 0 ? 0 : fish / trips;
  bool get reliable => trips >= minReliableTrips;
}

/// 일지를 [keyOf]로 묶어 성적을 낸다. 키가 null인 일지는 뺀다. 출조당 마릿수 높은 순(같으면 출조 수 많은 순).
List<GroupStat<K>> groupStats<K>(Iterable<CatchLogView> logs, K? Function(CatchLogView) keyOf) {
  final trips = <K, int>{};
  final fish = <K, int>{};
  final zero = <K, int>{};
  for (final l in logs) {
    final k = keyOf(l);
    if (k == null) continue;
    trips[k] = (trips[k] ?? 0) + 1;
    fish[k] = (fish[k] ?? 0) + l.totalCount;
    if (l.totalCount == 0) zero[k] = (zero[k] ?? 0) + 1;
  }
  final list = [
    for (final k in trips.keys)
      GroupStat<K>(key: k, trips: trips[k]!, fish: fish[k]!, zeroTrips: zero[k] ?? 0),
  ];
  list.sort((a, b) {
    final c = b.perTrip.compareTo(a.perTrip);
    return c != 0 ? c : b.trips.compareTo(a.trips);
  });
  return list;
}

List<GroupStat<TimeBand>> timeBandStats(Iterable<CatchLogView> logs) =>
    groupStats(logs, (l) => timeBandOf(l.fishedAt));

/// 달(1~12)별 성적. 해마다의 같은 달을 합친다.
List<GroupStat<int>> monthStats(Iterable<CatchLogView> logs) =>
    groupStats(logs, (l) => l.fishedAt.toLocal().month);

List<GroupStat<String>> pointStats(Iterable<CatchLogView> logs) =>
    groupStats(logs, (l) => l.pointId);

enum WindBand { calm, moderate, strong }

extension WindBandLabel on WindBand {
  String get label => switch (this) {
        WindBand.calm => '바람 약함(3m/s 미만)',
        WindBand.moderate => '바람 보통(3~7m/s)',
        WindBand.strong => '바람 강함(7m/s 이상)',
      };
}

WindBand windBandOf(double mps) => mps < 3 ? WindBand.calm : (mps < 7 ? WindBand.moderate : WindBand.strong);

/// 일지에 자동으로 붙은 날씨의 풍속 구간별 성적. 환경이 붙지 않은 일지는 뺀다.
List<GroupStat<WindBand>> windStats(Iterable<CatchLogView> logs) => groupStats(logs, (l) {
      final w = l.environment?.forecast?.weather?.windMps;
      return w == null ? null : windBandOf(w);
    });

/// 전체 요약.
class OverallSummary {
  const OverallSummary({required this.trips, required this.fish, required this.zeroTrips, required this.firstAt, required this.lastAt});

  final int trips;
  final int fish;
  final int zeroTrips;
  final DateTime? firstAt;
  final DateTime? lastAt;

  double get perTrip => trips == 0 ? 0 : fish / trips;

  /// 꽝 비율(0~1).
  double get zeroRate => trips == 0 ? 0 : zeroTrips / trips;
}

OverallSummary summarize(Iterable<CatchLogView> logs) {
  var trips = 0, fish = 0, zero = 0;
  DateTime? first, last;
  for (final l in logs) {
    trips++;
    fish += l.totalCount;
    if (l.totalCount == 0) zero++;
    if (first == null || l.fishedAt.isBefore(first)) first = l.fishedAt;
    if (last == null || l.fishedAt.isAfter(last)) last = l.fishedAt;
  }
  return OverallSummary(trips: trips, fish: fish, zeroTrips: zero, firstAt: first, lastAt: last);
}

/// 지금 가면 좋을 포인트 후보 하나.
class SpotRecommendation {
  const SpotRecommendation({
    required this.pointId,
    required this.score,
    required this.trips,
    required this.fish,
    required this.similarTrips,
    required this.topSpecies,
  });

  final String pointId;

  /// 비슷한 시기·시간대에 가중한 출조당 마릿수(표본이 적으면 전체 평균 쪽으로 당긴 값).
  final double score;

  /// 이 포인트의 전체 출조 수와 마릿수.
  final int trips;
  final int fish;

  /// 그중 지금과 비슷한 시기(앞뒤 1달) 출조 수.
  final int similarTrips;

  /// 이 포인트에서 가장 많이 잡은 어종 코드(없으면 null).
  final String? topSpecies;
}

/// 내 기록에서 "지금(달·시간대)" 가기 좋은 포인트를 점수순으로 최대 [limit]개.
///
/// 출조마다 비슷한 시기(앞뒤 1달)면 1.0, 아니면 0.4, 같은 시간대면 1.0, 아니면 0.6을 곱해 가중 평균을 낸다.
/// 한두 번의 우연한 대박이 순위를 뒤집지 않도록, 가중 평균은 내 전체 평균 쪽으로 [priorWeight]만큼 당긴다.
/// 포인트가 연결된 출조가 [minLogsForRecommendation]개 미만이면 빈 목록(기록이 더 필요하다).
List<SpotRecommendation> recommendSpots(
  Iterable<CatchLogView> logs, {
  required DateTime now,
  Genre? genre,
  int limit = 3,
  double priorWeight = 3,
}) {
  final withPoint = [
    for (final l in logs)
      if (l.pointId != null && (genre == null || l.genre == genre)) l,
  ];
  if (withPoint.length < minLogsForRecommendation) return const [];

  final month = now.toLocal().month;
  final band = timeBandOf(now);
  final overallMean = withPoint.fold<int>(0, (a, l) => a + l.totalCount) / withPoint.length;

  final weightSum = <String, double>{};
  final valueSum = <String, double>{};
  final trips = <String, int>{};
  final fish = <String, int>{};
  final similar = <String, int>{};
  final species = <String, Map<String, int>>{};

  for (final l in withPoint) {
    final id = l.pointId!;
    final seasonal = isWithinMonths(l.fishedAt.toLocal().month, month, 1);
    final w = (seasonal ? 1.0 : 0.4) * (timeBandOf(l.fishedAt) == band ? 1.0 : 0.6);
    weightSum[id] = (weightSum[id] ?? 0) + w;
    valueSum[id] = (valueSum[id] ?? 0) + w * l.totalCount;
    trips[id] = (trips[id] ?? 0) + 1;
    fish[id] = (fish[id] ?? 0) + l.totalCount;
    if (seasonal) similar[id] = (similar[id] ?? 0) + 1;
    final m = species.putIfAbsent(id, () => {});
    for (final it in l.items) {
      m[it.speciesCode] = (m[it.speciesCode] ?? 0) + it.count;
    }
  }

  String? top(Map<String, int> m) {
    String? best;
    for (final e in m.entries) {
      if (best == null || e.value > m[best]! || (e.value == m[best] && e.key.compareTo(best) < 0)) {
        best = e.key;
      }
    }
    return best;
  }

  final list = [
    for (final id in trips.keys)
      SpotRecommendation(
        pointId: id,
        score: (valueSum[id]! + priorWeight * overallMean) / (weightSum[id]! + priorWeight),
        trips: trips[id]!,
        fish: fish[id]!,
        similarTrips: similar[id] ?? 0,
        topSpecies: top(species[id]!),
      ),
  ];
  list.sort((a, b) {
    final c = b.score.compareTo(a.score);
    return c != 0 ? c : a.pointId.compareTo(b.pointId);
  });
  return list.take(limit).toList();
}
