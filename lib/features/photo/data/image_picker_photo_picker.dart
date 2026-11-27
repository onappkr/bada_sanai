import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../domain/photo_compressor.dart';
import '../domain/photo_models.dart';
import '../domain/photo_ports.dart';

/// compute()는 최상위 함수만 받는다. 별도 isolate에서 돌려 화면이 멈추지 않게 한다.
CompressedPhoto _compressInIsolate(Uint8List bytes) => compressPhoto(bytes);

/// image_picker 기반. 고른 사진은 긴 변 [PhotoLimits.maxSidePx] 이하, [PhotoLimits.maxBytes] 이하의
/// JPEG로 줄여서 돌려준다(계획서 B3). 선택기가 먼저 한 번 줄여 오기 때문에 압축기가 다루는 크기가 작다.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _quality = 85;

  @override
  Future<List<PickedPhoto>> pickFromGallery() async {
    final files = await _picker.pickMultiImage(
      maxWidth: PhotoLimits.maxSidePx.toDouble(),
      maxHeight: PhotoLimits.maxSidePx.toDouble(),
      imageQuality: _quality,
    );
    return [for (final f in files) await _read(f)];
  }

  @override
  Future<PickedPhoto?> takePhoto() async {
    final f = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: PhotoLimits.maxSidePx.toDouble(),
      maxHeight: PhotoLimits.maxSidePx.toDouble(),
      imageQuality: _quality,
    );
    return f == null ? null : _read(f);
  }

  Future<PickedPhoto> _read(XFile f) async {
    final raw = await f.readAsBytes();
    final c = await compute(_compressInIsolate, raw);
    // JPEG로 다시 만들었으면 확장자도 맞춘다. 읽지 못한 형식은 원본 이름을 그대로 둔다.
    final name = c.reencoded ? '${p.basenameWithoutExtension(f.name)}.jpg' : f.name;
    return PickedPhoto(name: name, bytes: c.bytes);
  }
}
