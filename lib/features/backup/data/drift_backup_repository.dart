import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/backup_models.dart';
import '../domain/backup_ports.dart';

class DriftBackupRepository implements BackupRepository {
  DriftBackupRepository(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Future<BackupSnapshot> snapshot() async {
    return BackupSnapshot(
      exportedAt: _now().toUtc(),
      points: await _db.select(_db.points).get(),
      logs: await _db.select(_db.catchLogs).get(),
      items: await _db.select(_db.catchItems).get(),
      photos: await _db.select(_db.photos).get(),
    );
  }

  @override
  Future<RestoreResult> restore(BackupSnapshot s) {
    return _db.transaction(() async {
      var added = 0, updated = 0, skipped = 0;

      // 1) 포인트. 일지가 참조하므로 먼저 넣는다.
      for (final p in s.points) {
        final cur = await (_db.select(_db.points)..where((t) => t.id.equals(p.id)))
            .getSingleOrNull();
        if (cur == null) {
          await _db.into(_db.points).insert(p);
          added++;
        } else if (p.updatedAt.isAfter(cur.updatedAt)) {
          await _db.update(_db.points).replace(p);
          updated++;
        } else {
          skipped++;
        }
      }
      final pointIds =
          (await _db.select(_db.points).get()).map((e) => e.id).toSet();

      // 2) 일지와 조과. 일지가 추가·갱신될 때만 그 일지의 조과를 통째로 교체한다.
      final itemsByLog = <String, List<CatchItem>>{};
      for (final i in s.items) {
        itemsByLog.putIfAbsent(i.logId, () => []).add(i);
      }
      for (var l in s.logs) {
        // 참조하는 포인트가 기기에도 백업에도 없으면 연결만 끊는다.
        if (l.pointId != null && !pointIds.contains(l.pointId)) {
          l = l.copyWith(pointId: const Value(null));
        }
        final cur = await (_db.select(_db.catchLogs)..where((t) => t.id.equals(l.id)))
            .getSingleOrNull();
        if (cur == null) {
          await _db.into(_db.catchLogs).insert(l);
          added++;
        } else if (l.updatedAt.isAfter(cur.updatedAt)) {
          await _db.update(_db.catchLogs).replace(l);
          updated++;
        } else {
          skipped++;
          continue;
        }
        await (_db.delete(_db.catchItems)..where((t) => t.logId.equals(l.id))).go();
        for (final i in itemsByLog[l.id] ?? const <CatchItem>[]) {
          await _db.into(_db.catchItems).insert(i);
        }
      }
      // 3) 사진. 같은 id가 이미 있으면 그대로 두고, 주인(일지·포인트)이 있는 것만 연결한다.
      final logIds = (await _db.select(_db.catchLogs).get()).map((e) => e.id).toSet();
      var photosAdded = 0;
      for (final ph in s.photos) {
        final ownerExists = ph.ownerType == OwnerType.log
            ? logIds.contains(ph.ownerId)
            : pointIds.contains(ph.ownerId);
        if (!ownerExists) continue;
        final cur = await (_db.select(_db.photos)..where((t) => t.id.equals(ph.id)))
            .getSingleOrNull();
        if (cur != null) continue;
        await _db.into(_db.photos).insert(ph);
        photosAdded++;
      }
      return RestoreResult(
          added: added, updated: updated, skipped: skipped, photosAdded: photosAdded);
    });
  }
}
