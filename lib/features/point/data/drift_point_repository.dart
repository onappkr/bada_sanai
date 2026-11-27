import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/point_models.dart';
import '../domain/point_repository.dart';

class DriftPointRepository implements PointRepository {
  DriftPointRepository(
    this._db, {
    this._uuid = const Uuid(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Stream<List<PointView>> watchAll() {
    final q = _db.select(_db.points)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return q.watch().map((rows) => rows.map(_toView).toList());
  }

  @override
  Stream<PointView?> watchOne(String id) {
    final q = _db.select(_db.points)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.watchSingleOrNull().map((r) => r == null ? null : _toView(r));
  }

  @override
  Future<String> create(PointInput input) async {
    _check(input);
    final id = _uuid.v4();
    final now = _now().toUtc();
    await _db.into(_db.points).insert(PointsCompanion.insert(
          id: id,
          name: input.name.trim(),
          lat: input.lat,
          lng: input.lng,
          genre: Value(input.genre),
          memo: Value(_blankToNull(input.memo)),
          source: input.source,
          createdAt: now,
          updatedAt: now,
        ));
    return id;
  }

  @override
  Future<void> update(String id, PointInput input) async {
    _check(input);
    final updated = await (_db.update(_db.points)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .write(PointsCompanion(
      name: Value(input.name.trim()),
      lat: Value(input.lat),
      lng: Value(input.lng),
      genre: Value(input.genre),
      memo: Value(_blankToNull(input.memo)),
      updatedAt: Value(_now().toUtc()),
    ));
    if (updated == 0) throw StateError('포인트를 찾을 수 없습니다: $id');
  }

  @override
  Future<void> delete(String id) async {
    final now = _now().toUtc();
    await (_db.update(_db.points)..where((t) => t.id.equals(id))).write(
      PointsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  static void _check(PointInput i) {
    final err = validatePointInput(name: i.name, lat: i.lat, lng: i.lng);
    if (err != null) throw ArgumentError(err);
  }

  static String? _blankToNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static PointView _toView(Point r) => PointView(
        id: r.id,
        name: r.name,
        lat: r.lat,
        lng: r.lng,
        genre: r.genre,
        memo: r.memo,
        source: r.source,
      );
}
