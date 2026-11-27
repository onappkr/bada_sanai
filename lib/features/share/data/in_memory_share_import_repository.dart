import '../../point/domain/point_models.dart';
import '../../point/domain/point_repository.dart';
import '../domain/share_import_repository.dart';
import '../domain/shared_point.dart';

/// 메모리 구현. 미리보기·테스트용이며 [PointRepository]에 포인트를 만든다.
class InMemoryShareImportRepository implements ShareImportRepository {
  InMemoryShareImportRepository(this._points);

  final PointRepository _points;
  final Map<String, String> _byFingerprint = {};

  @override
  Future<ShareImportResult> import(SharedPoint point, String fingerprint) async {
    final known = _byFingerprint[fingerprint];
    if (known != null && await _points.watchOne(known).first != null) {
      return ShareImportResult(pointId: known, alreadyImported: true);
    }
    final id = await _points.create(PointInput(
      name: point.name,
      lat: point.lat,
      lng: point.lng,
      genre: point.genre,
      memo: point.memo,
      source: PointSource.shared,
    ));
    _byFingerprint[fingerprint] = id;
    return ShareImportResult(pointId: id, alreadyImported: false);
  }
}
