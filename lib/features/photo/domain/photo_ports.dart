import 'package:flutter/painting.dart' show ImageProvider;

import 'photo_models.dart';

/// 사진 메타데이터 저장소.
abstract interface class PhotoRepository {
  Stream<List<PhotoView>> watchByOwner(OwnerType type, String ownerId);

  /// 소유자의 사진을 [keep]에 있는 id만 남기고 지운 뒤 [addPaths]를 추가한다.
  /// 지워진 사진의 파일 경로를 돌려주므로 호출한 쪽이 파일을 삭제한다.
  Future<List<String>> replaceForOwner(
    OwnerType type,
    String ownerId, {
    required Set<String> keep,
    required List<String> addPaths,
  });
}

/// 사진 파일 보관소. 구현은 앱 문서 폴더(기기) 또는 메모리(미리보기·테스트).
abstract interface class PhotoStore {
  /// 파일을 저장하고 상대 경로를 돌려준다.
  Future<String> save(PickedPhoto photo);

  Future<void> delete(String path);

  /// 보관 중인 사진 파일을 모두 지운다. 이미 없으면 아무것도 하지 않는다.
  Future<void> deleteAll();

  ImageProvider imageFor(String path);
}

/// 갤러리·카메라에서 사진을 고르는 창구.
abstract interface class PhotoPicker {
  Future<List<PickedPhoto>> pickFromGallery();

  /// 카메라를 쓸 수 없거나 취소하면 null.
  Future<PickedPhoto?> takePhoto();
}
