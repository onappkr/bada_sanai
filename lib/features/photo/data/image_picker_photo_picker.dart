import 'package:image_picker/image_picker.dart';

import '../domain/photo_models.dart';
import '../domain/photo_ports.dart';

/// image_picker 기반. 용량을 줄이려고 긴 변 1600px, 품질 85로 줄여 가져온다.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _maxSide = 1600.0;
  static const _quality = 85;

  @override
  Future<List<PickedPhoto>> pickFromGallery() async {
    final files = await _picker.pickMultiImage(
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    return [for (final f in files) await _read(f)];
  }

  @override
  Future<PickedPhoto?> takePhoto() async {
    final f = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    return f == null ? null : _read(f);
  }

  Future<PickedPhoto> _read(XFile f) async =>
      PickedPhoto(name: f.name, bytes: await f.readAsBytes());
}
