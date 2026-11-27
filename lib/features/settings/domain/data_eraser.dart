/// 기기에 저장된 내 기록(일지·포인트·사진 정보·경로 등)을 모두 지우는 창구.
/// 앱 설정(온보딩 완료 여부 등)은 지우지 않는다.
abstract interface class DataEraser {
  Future<void> eraseAll();
}

/// 지우기 결과.
class EraseResult {
  const EraseResult({required this.photoFilesError});

  /// 기록은 모두 지웠지만 사진 파일 삭제에 실패했다면 그 오류. 성공이면 null.
  final Object? photoFilesError;

  bool get complete => photoFilesError == null;
}

/// 내 데이터를 모두 지운다. 기록(DB)을 먼저 지우고 [deletePhotoFiles]로 사진 파일을 지운다.
/// 기록 삭제가 실패하면 예외를 그대로 던지고 사진 파일은 건드리지 않는다
/// (기록이 남았는데 사진만 사라지는 일을 막는다).
/// 기록은 지웠는데 파일 삭제만 실패하면 [EraseResult.photoFilesError]에 담아 돌려준다.
Future<EraseResult> eraseAllUserData({
  required DataEraser eraser,
  required Future<void> Function() deletePhotoFiles,
}) async {
  await eraser.eraseAll();
  try {
    await deletePhotoFiles();
    return const EraseResult(photoFilesError: null);
  } catch (e) {
    return EraseResult(photoFilesError: e);
  }
}
