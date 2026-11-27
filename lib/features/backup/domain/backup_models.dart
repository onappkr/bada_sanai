import '../../../core/db/app_database.dart' show CatchItem, CatchLog, Photo, Point;

/// 백업 대상 전체. 삭제 표시된 행도 포함해 복원 시 삭제도 전달된다.
/// 사진은 메타데이터([photos])만 들고 있고, 파일은 zip 꾸러미에 따로 담긴다(backup_archive.dart).
class BackupSnapshot {
  const BackupSnapshot({
    required this.exportedAt,
    required this.points,
    required this.logs,
    required this.items,
    this.photos = const [],
  });

  final DateTime exportedAt;
  final List<Point> points;
  final List<CatchLog> logs;
  final List<CatchItem> items;
  final List<Photo> photos;

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
    this.photosAdded = 0,
  });

  final int added;
  final int updated;
  final int skipped;

  /// 새로 연결된 사진 수([total]에는 넣지 않는다).
  final int photosAdded;

  int get total => added + updated + skipped;
}
