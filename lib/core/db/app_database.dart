import 'package:drift/drift.dart';

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
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
              'CREATE INDEX idx_catch_log_fished_at ON catch_logs(fished_at)');
          await customStatement(
              'CREATE INDEX idx_catch_item_log_id ON catch_items(log_id)');
          await customStatement(
              'CREATE INDEX idx_point_lat_lng ON points(lat, lng)');
          await customStatement(
              'CREATE INDEX idx_track_started_at ON tracks(started_at)');
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
