import 'dart:typed_data';

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
  Future<void> export(String filename, Uint8List bytes, String mimeType);

  /// 사용자가 고른 파일의 내용. 취소하면 null.
  Future<Uint8List?> pick();
}

/// 백업에 넣고 복원할 사진 파일 창구(앱 사진 폴더).
abstract interface class BackupPhotoFiles {
  /// 없으면 null.
  Future<Uint8List?> read(String path);

  Future<void> write(String path, Uint8List bytes);

  Future<void> delete(String path);
}
