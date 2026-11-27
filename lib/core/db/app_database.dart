import 'package:drift/drift.dart';

import 'schema_versions.dart';
import 'tables.dart';

export 'tables.dart' show Genre, PointSource, TrackStatus, CandidateStatus, OwnerType;

part 'app_database.g.dart';

@DriftDatabase(tables: [
  CatchLogs,
  CatchItems,
  Photos,
  Points,
  Tracks,
  TrackPoints,
  PointCandidates,
  ForecastCache,
  ShareImports,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // 인덱스는 tables.dart의 @TableIndex로 선언되어 createAll()이 함께 만든다.
        onCreate: (m) => m.createAll(),
        // 스키마를 바꿀 때는 schemaVersion을 올리고 drift_schemas/를 다시 덤프한 뒤
        // schema_versions.dart를 재생성하면 단계별 마이그레이션(from1To2 ...)을 채울 수 있다.
        onUpgrade: stepByStep(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
