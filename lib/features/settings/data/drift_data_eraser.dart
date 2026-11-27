import '../../../core/db/app_database.dart';
import '../domain/data_eraser.dart';

class DriftDataEraser implements DataEraser {
  DriftDataEraser(this._db);

  final AppDatabase _db;

  /// 외래키 순서(자식 먼저)대로 한 트랜잭션에서 지운다. 중간에 실패하면 모두 되돌아간다.
  /// app_setting은 사용자 기록이 아니라 설정이라 남긴다.
  @override
  Future<void> eraseAll() {
    return _db.transaction(() async {
      await _db.delete(_db.shareImports).go();
      await _db.delete(_db.photos).go();
      await _db.delete(_db.catchItems).go();
      await _db.delete(_db.pointCandidates).go();
      await _db.delete(_db.trackPoints).go();
      await _db.delete(_db.catchLogs).go();
      await _db.delete(_db.tracks).go();
      await _db.delete(_db.points).go();
      await _db.delete(_db.forecastCache).go();
    });
  }
}
