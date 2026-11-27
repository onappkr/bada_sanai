import '../../../core/db/app_database.dart' show CatchItem, CatchLog, Point;

/// 백업 대상 전체. 삭제 표시된 행도 포함해 복원 시 삭제도 전달된다.
/// 사진 파일은 용량 때문에 1차 백업에 포함하지 않는다.
class BackupSnapshot {
  const BackupSnapshot({
    required this.exportedAt,
    required this.points,
    required this.logs,
    required this.items,
  });

  final DateTime exportedAt;
  final List<Point> points;
  final List<CatchLog> logs;
  final List<CatchItem> items;

  /// 삭제 표시되지 않은 항목 수(화면 표시용).
  int get livePointCount => points.where((p) => p.deletedAt == null).length;
  int get liveLogCount => logs.where((l) => l.deletedAt == null).length;
}

/// 복원 결과. 기기의 데이터가 더 최신이면 건드리지 않고 건너뛴다.
class RestoreResult {
  const RestoreResult({
    required this.added,
    required this.updated,
    required this.skipped,
  });

  final int added;
  final int updated;
  final int skipped;

  int get total => added + updated + skipped;
}
