import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../data/drift_catch_log_repository.dart';
import '../domain/catch_log_models.dart';
import '../domain/catch_log_repository.dart';
import '../domain/log_period.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'bada_sanai'));
  ref.onDispose(db.close);
  return db;
});

final catchLogRepositoryProvider = Provider<CatchLogRepository>(
  (ref) => DriftCatchLogRepository(ref.watch(databaseProvider)),
);

/// 목록 장르 필터. null이면 전체.
class GenreFilter extends Notifier<Genre?> {
  @override
  Genre? build() => null;

  void select(Genre? genre) => state = genre;
}

final genreFilterProvider =
    NotifierProvider<GenreFilter, Genre?>(GenreFilter.new);

/// 목록 기간 필터. 기본은 전체 기간.
class PeriodFilter extends Notifier<LogPeriod> {
  @override
  LogPeriod build() => LogPeriod.all;

  void select(LogPeriod period) => state = period;
}

final periodFilterProvider =
    NotifierProvider<PeriodFilter, LogPeriod>(PeriodFilter.new);

/// 장르(저장소에서)와 기간(여기서)으로 거른 일지 목록.
final catchLogsProvider = StreamProvider.autoDispose<List<CatchLogView>>((ref) {
  final genre = ref.watch(genreFilterProvider);
  final period = ref.watch(periodFilterProvider);
  return ref
      .watch(catchLogRepositoryProvider)
      .watchAll(genre: genre)
      .map((logs) => filterByPeriod(logs, period, DateTime.now()));
});

/// 특정 포인트에 연결된 일지(포인트 상세용).
final catchLogsByPointProvider =
    StreamProvider.autoDispose.family<List<CatchLogView>, String>((ref, pointId) {
  return ref.watch(catchLogRepositoryProvider).watchAll(pointId: pointId);
});

final catchLogProvider =
    StreamProvider.autoDispose.family<CatchLogView?, String>((ref, id) {
  return ref.watch(catchLogRepositoryProvider).watchOne(id);
});
