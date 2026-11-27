import 'dart:typed_data';

export '../../../core/db/app_database.dart' show OwnerType;

/// 저장된 사진 1장. [filePath]는 [PhotoStore]가 해석하는 앱 저장소 내 상대 경로.
class PhotoView {
  const PhotoView({required this.id, required this.filePath});

  final String id;
  final String filePath;
}

/// 갤러리·카메라에서 막 고른 사진. 저장 버튼을 누르기 전에는 메모리에만 있다.
class PickedPhoto {
  const PickedPhoto({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
