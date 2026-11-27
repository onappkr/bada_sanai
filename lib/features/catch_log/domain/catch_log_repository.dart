import 'catch_log_models.dart';

/// 일지 저장소 인터페이스. 구현은 data 계층(Drift)에 둔다.
abstract interface class CatchLogRepository {
  /// 삭제되지 않은 일지를 낚시 시각 내림차순으로 관찰한다.
  /// [genre], [pointId]를 주면 해당 조건의 일지만 관찰한다.
  Stream<List<CatchLogView>> watchAll({Genre? genre, String? pointId});

  Stream<CatchLogView?> watchOne(String id);

  /// 새 일지의 id를 반환한다.
  Future<String> create(CatchLogInput input);

  Future<void> update(String id, CatchLogInput input);

  /// 삭제 표시(soft delete). 동기화를 위해 행은 남긴다.
  Future<void> delete(String id);
}
