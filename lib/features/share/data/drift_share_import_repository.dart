import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/share_import_repository.dart';
import '../domain/shared_point.dart';

class DriftShareImportRepository implements ShareImportRepository {
  DriftShareImportRepository(
    this._db, {
    this._uuid = const Uuid(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Future<ShareImportResult> import(SharedPoint point, String fingerprint) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.shareImports)
            ..where((t) => t.payloadHash.equals(fingerprint)))
          .getSingleOrNull();
      if (existing != null) {
        // 받은 뒤 사용자가 포인트를 삭제했다면 같은 링크로 다시 받을 수 있게 한다.
        final alive = await (_db.select(_db.points)
              ..where((t) => t.id.equals(existing.pointId) & t.deletedAt.isNull()))
            .getSingleOrNull();
        if (alive != null) {
          return ShareImportResult(pointId: existing.pointId, alreadyImported: true);
        }
        await (_db.delete(_db.shareImports)..where((t) => t.id.equals(existing.id)))
            .go();
      }

      final now = _now().toUtc();
      final pointId = _uuid.v4();
      await _db.into(_db.points).insert(PointsCompanion.insert(
            id: pointId,
            name: point.name,
            lat: point.lat,
            lng: point.lng,
            genre: Value(point.genre),
            memo: Value(point.memo),
            source: PointSource.shared,
            createdAt: now,
            updatedAt: now,
          ));
      await _db.into(_db.shareImports).insert(ShareImportsCompanion.insert(
            id: _uuid.v4(),
            pointId: pointId,
            payloadHash: fingerprint,
            importedAt: now,
          ));
      return ShareImportResult(pointId: pointId, alreadyImported: false);
    });
  }
}
