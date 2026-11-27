import 'backup_models.dart';

abstract interface class BackupRepository {
  Future<BackupSnapshot> snapshot();

  /// 항목별로 id가 같은 것끼리 비교해 더 최신인 쪽을 남긴다(병합).
  /// 없는 항목은 추가, 백업이 더 최신이면 갱신, 아니면 건너뛴다.
  Future<RestoreResult> restore(BackupSnapshot snapshot);
}

/// 백업 파일을 내보내고 불러오는 창구(공유창·파일 선택).
abstract interface class BackupFileGateway {
  /// 파일로 만들어 공유창(드라이브·메신저·파일 저장 등)을 연다.
  Future<void> export(String filename, String json);

  /// 사용자가 고른 파일의 내용. 취소하면 null.
  Future<String?> pick();
}
