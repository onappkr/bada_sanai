import '../../catch_log/domain/catch_log_models.dart';

/// 한 어종의 내 조과 통계.
class SpeciesStat {
  const SpeciesStat({
    required this.speciesCode,
    required this.totalCount,
    required this.logCount,
    this.maxLengthCm,
  });

  final String speciesCode;

  /// 잡은 마릿수 합계.
  final int totalCount;

  /// 이 어종을 잡은 일지 수(출조 횟수).
  final int logCount;

  /// 기록된 가장 큰 크기. 크기를 적은 기록이 없으면 null.
  final double? maxLengthCm;
}

/// [month]가 [center] 달에서 앞뒤로 [window]달 이내인지. 12월과 1월은 이어진다.
bool isWithinMonths(int month, int center, int window) {
  final diff = (month - center).abs();
  final circular = diff > 6 ? 12 - diff : diff;
  return circular <= window;
}

/// 내 일지에서 "이 시기(지금 달 앞뒤 [window]달)"에 잡은 어종을 많이 잡은 순으로 모은다.
/// 연도는 따지지 않는다. 마릿수가 같으면 출조 횟수, 그다음 이름 순.
///
/// 외부 자료 없이 내 기록만 쓰므로 기록이 적으면 결과도 적다.
List<SpeciesStat> speciesRanking(
  Iterable<CatchLogView> logs, {
  required DateTime now,
  int window = 1,
}) {
  final total = <String, int>{};
  final logCount = <String, int>{};
  final maxLen = <String, double>{};

  for (final log in logs) {
    if (!isWithinMonths(log.fishedAt.toLocal().month, now.month, window)) continue;
    // 한 일지에 같은 어종이 여러 줄이어도 출조 횟수는 한 번으로 센다.
    final seen = <String>{};
    for (final it in log.items) {
      total[it.speciesCode] = (total[it.speciesCode] ?? 0) + it.count;
      if (seen.add(it.speciesCode)) {
        logCount[it.speciesCode] = (logCount[it.speciesCode] ?? 0) + 1;
      }
      final len = it.lengthCm;
      if (len != null && len > (maxLen[it.speciesCode] ?? 0)) {
        maxLen[it.speciesCode] = len;
      }
    }
  }

  final list = [
    for (final code in total.keys)
      SpeciesStat(
        speciesCode: code,
        totalCount: total[code]!,
        logCount: logCount[code]!,
        maxLengthCm: maxLen[code],
      ),
  ];
  list.sort((a, b) {
    final byTotal = b.totalCount.compareTo(a.totalCount);
    if (byTotal != 0) return byTotal;
    final byLogs = b.logCount.compareTo(a.logCount);
    return byLogs != 0 ? byLogs : a.speciesCode.compareTo(b.speciesCode);
  });
  return list;
}
