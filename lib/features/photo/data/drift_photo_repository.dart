import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/photo_models.dart';
import '../domain/photo_ports.dart';

class DriftPhotoRepository implements PhotoRepository {
  DriftPhotoRepository(
    this._db, {
    this._uuid = const Uuid(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Stream<List<PhotoView>> watchByOwner(OwnerType type, String ownerId) {
    final q = _db.select(_db.photos)
      ..where((t) => t.ownerType.equalsValue(type) & t.ownerId.equals(ownerId))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt), (t) => OrderingTerm.asc(t.id)]);
    return q.watch().map(
        (rows) => [for (final r in rows) PhotoView(id: r.id, filePath: r.filePath)]);
  }

  @override
  Future<List<String>> replaceForOwner(
    OwnerType type,
    String ownerId, {
    required Set<String> keep,
    required List<String> addPaths,
  }) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.photos)
            ..where(
                (t) => t.ownerType.equalsValue(type) & t.ownerId.equals(ownerId)))
          .get();
      final removed = existing.where((r) => !keep.contains(r.id)).toList();
      if (removed.isNotEmpty) {
        await (_db.delete(_db.photos)
              ..where((t) => t.id.isIn(removed.map((r) => r.id).toList())))
            .go();
      }
      final now = _now().toUtc();
      for (final path in addPaths) {
        await _db.into(_db.photos).insert(PhotosCompanion.insert(
              id: _uuid.v4(),
              ownerType: type,
              ownerId: ownerId,
              filePath: path,
              createdAt: now,
            ));
      }
      return [for (final r in removed) r.filePath];
    });
  }
}
