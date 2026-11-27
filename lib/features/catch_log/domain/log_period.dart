import 'catch_log_models.dart';

/// 일지 목록의 기간 필터.
enum LogPeriod {
  all('전체 기간'),
  thisMonth('이번 달'),
  last3Months('최근 3개월'),
  thisYear('올해');

  const LogPeriod(this.label);

  final String label;

  /// [time]이 [now] 기준 이 기간에 드는지. 로컬 시각 기준이며 미래 시각도 포함한다.
  bool contains(DateTime time, DateTime now) {
    final t = time.toLocal();
    final n = now.toLocal();
    switch (this) {
      case LogPeriod.all:
        return true;
      case LogPeriod.thisMonth:
        return t.year == n.year && t.month == n.month;
      case LogPeriod.last3Months:
        // 오늘이 속한 달을 포함해 세 달: 이번 달 1일의 두 달 전 1일부터.
        return !t.isBefore(DateTime(n.year, n.month - 2));
      case LogPeriod.thisYear:
        return t.year == n.year;
    }
  }
}

/// [period]에 드는 일지만 남긴다. 순서는 그대로 둔다.
List<CatchLogView> filterByPeriod(
  Iterable<CatchLogView> logs,
  LogPeriod period,
  DateTime now,
) =>
    [
      for (final l in logs)
        if (period.contains(l.fishedAt, now)) l,
    ];
