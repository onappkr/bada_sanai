import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/catch_log_models.dart';
import '../domain/log_environment.dart';
import '../domain/catch_log_repository.dart';

class DriftCatchLogRepository implements CatchLogRepository {
  DriftCatchLogRepository(
    this._db, {
    this._uuid = const Uuid(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Stream<List<CatchLogView>> watchAll({Genre? genre, String? pointId}) {
    final q = _db.select(_db.catchLogs)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.fishedAt)]);
    if (genre != null) q.where((t) => t.genre.equalsValue(genre));
    if (pointId != null) q.where((t) => t.pointId.equals(pointId));
    return q.watch().asyncMap(_withItems);
  }

  @override
  Stream<CatchLogView?> watchOne(String id) {
    final q = _db.select(_db.catchLogs)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      return (await _withItems([row])).single;
    });
  }

  @override
  Future<String> create(CatchLogInput input) async {
    final id = _uuid.v4();
    final now = _now().toUtc();
    await _db.transaction(() async {
      await _db.into(_db.catchLogs).insert(CatchLogsCompanion.insert(
            id: id,
            genre: input.genre,
            fishedAt: input.fishedAt.toUtc(),
            pointId: Value(input.pointId),
            memo: Value(_blankToNull(input.memo)),
            genreDetail: Value(_encodeDetail(input.genreDetail)),
            lat: Value(input.environment?.lat),
            lng: Value(input.environment?.lng),
            env: input.environment == null
                ? const Value.absent()
                : Value(input.environment!.toEnvJson()),
            createdAt: now,
            updatedAt: now,
          ));
      await _insertItems(id, input.items);
    });
    return id;
  }

  @override
  Future<void> update(String id, CatchLogInput input) async {
    await _db.transaction(() async {
      final updated = await (_db.update(_db.catchLogs)
            ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
          .write(CatchLogsCompanion(
        genre: Value(input.genre),
        fishedAt: Value(input.fishedAt.toUtc()),
        pointId: Value(input.pointId),
        memo: Value(_blankToNull(input.memo)),
        genreDetail: Value(_encodeDetail(input.genreDetail)),
        // 환경은 일지를 처음 쓸 때만 붙으므로, 수정에서 값이 없으면 저장된 값을 그대로 둔다.
        lat: input.environment == null ? const Value.absent() : Value(input.environment!.lat),
        lng: input.environment == null ? const Value.absent() : Value(input.environment!.lng),
        env: input.environment == null
            ? const Value.absent()
            : Value(input.environment!.toEnvJson()),
        updatedAt: Value(_now().toUtc()),
      ));
      if (updated == 0) throw StateError('일지를 찾을 수 없습니다: $id');
      await (_db.delete(_db.catchItems)..where((t) => t.logId.equals(id))).go();
      await _insertItems(id, input.items);
    });
  }

  @override
  Future<void> delete(String id) async {
    final now = _now().toUtc();
    await (_db.update(_db.catchLogs)..where((t) => t.id.equals(id))).write(
      CatchLogsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> _insertItems(String logId, List<CatchItemInput> items) async {
    for (final it in items) {
      await _db.into(_db.catchItems).insert(CatchItemsCompanion.insert(
            id: _uuid.v4(),
            logId: logId,
            speciesCode: it.speciesCode,
            lengthCm: Value(it.lengthCm),
            count: Value(it.count),
            memo: Value(_blankToNull(it.memo)),
          ));
    }
  }

  Future<List<CatchLogView>> _withItems(List<CatchLog> logs) async {
    if (logs.isEmpty) return const [];
    final ids = logs.map((l) => l.id).toList();
    final rows = await (_db.select(_db.catchItems)
          ..where((t) => t.logId.isIn(ids)))
        .get();
    final byLog = <String, List<CatchItemInput>>{};
    for (final r in rows) {
      byLog.putIfAbsent(r.logId, () => []).add(CatchItemInput(
            speciesCode: r.speciesCode,
            lengthCm: r.lengthCm,
            count: r.count,
            memo: r.memo,
          ));
    }
    return [
      for (final l in logs)
        CatchLogView(
          id: l.id,
          genre: l.genre,
          fishedAt: l.fishedAt,
          pointId: l.pointId,
          memo: l.memo,
          genreDetail: _decodeDetail(l.genreDetail),
          items: byLog[l.id] ?? const [],
          environment: _environmentOf(l),
        ),
    ];
  }

  static LogEnvironment? _environmentOf(CatchLog l) {
    final env = LogEnvironment.fromColumns(lat: l.lat, lng: l.lng, envJson: l.env);
    return env.isEmpty ? null : env;
  }

  static String? _blankToNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static String _encodeDetail(Map<String, String> m) => jsonEncode({
        for (final e in m.entries)
          if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
      });

  static Map<String, String> _decodeDetail(String raw) {
    try {
      final d = jsonDecode(raw);
      if (d is Map) return {for (final e in d.entries) '${e.key}': '${e.value}'};
    } on FormatException {
      // 손상된 값은 빈 항목으로 취급한다.
    }
    return const {};
  }
}
