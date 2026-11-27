import 'point_models.dart';

/// 포인트 저장소 인터페이스. 구현은 data 계층에 둔다.
abstract interface class PointRepository {
  /// 삭제되지 않은 포인트를 이름순으로 관찰한다.
  Stream<List<PointView>> watchAll();

  Stream<PointView?> watchOne(String id);

  /// 새 포인트의 id를 반환한다. 입력이 올바르지 않으면 [ArgumentError].
  Future<String> create(PointInput input);

  /// 없는 포인트면 [StateError].
  Future<void> update(String id, PointInput input);

  /// 삭제 표시(soft delete).
  Future<void> delete(String id);
}
