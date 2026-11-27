import 'shared_point.dart';

class ShareImportResult {
  const ShareImportResult({required this.pointId, required this.alreadyImported});

  final String pointId;

  /// 같은 링크로 이미 받은 적이 있어 새로 저장하지 않았다.
  final bool alreadyImported;
}

abstract interface class ShareImportRepository {
  /// [fingerprint]가 처음이면 포인트(출처: 공유 받음)를 만들어 저장하고,
  /// 이미 받은 링크면 기존 포인트를 돌려준다. 한 트랜잭션으로 처리한다.
  Future<ShareImportResult> import(SharedPoint point, String fingerprint);
}
