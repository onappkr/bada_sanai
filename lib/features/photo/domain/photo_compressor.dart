import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// 사진 저장 규격: 긴 변 1280px 이하, 400KB 이하(계획서 B3).
abstract final class PhotoLimits {
  static const maxSidePx = 1280;
  static const maxBytes = 400 * 1024;

  /// 이 아래로는 화질을 낮추지 않는다(알아볼 수 없을 정도로 뭉개지는 것을 막는다).
  static const minQuality = 45;
}

/// 압축 결과.
class CompressedPhoto {
  const CompressedPhoto({
    required this.bytes,
    required this.width,
    required this.height,
    required this.reencoded,
  });

  final Uint8List bytes;
  final int width;
  final int height;

  /// 다시 인코딩했으면 true. 읽을 수 없는 형식이라 원본을 그대로 돌려줬으면 false.
  final bool reencoded;
}

/// [input]을 긴 변 [maxSidePx] 이하, [maxBytes] 이하의 JPEG로 줄인다.
///
/// - 확대하지 않는다. 이미 작으면 크기는 그대로 두고 용량만 맞춘다.
/// - EXIF 회전 정보를 픽셀에 반영한 뒤 다시 인코딩한다(재인코딩하면 EXIF가 사라져
///   그대로 두면 사진이 옆으로 누워 보인다).
/// - 화질을 85부터 [PhotoLimits.minQuality]까지 내려 보고, 그래도 크면 크기를 80%씩 줄인다.
/// - 이 앱이 읽지 못하는 형식(예: 일부 HEIC)은 원본을 그대로 돌려준다([CompressedPhoto.reencoded]가 false).
///
/// 순수 계산이라 무겁다. 화면 스레드에서 부르지 말고 별도 isolate에서 실행할 것.
CompressedPhoto compressPhoto(
  Uint8List input, {
  int maxSidePx = PhotoLimits.maxSidePx,
  int maxBytes = PhotoLimits.maxBytes,
}) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(input);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    return CompressedPhoto(bytes: input, width: 0, height: 0, reencoded: false);
  }

  var image = img.bakeOrientation(decoded);
  image = _fit(image, maxSidePx);

  var side = maxSidePx;
  while (true) {
    for (var quality = 85; quality >= PhotoLimits.minQuality; quality -= 10) {
      final bytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      if (bytes.length <= maxBytes) {
        return CompressedPhoto(
            bytes: bytes, width: image.width, height: image.height, reencoded: true);
      }
    }
    // 화질을 최저로 낮춰도 크면 크기를 줄여 다시 시도한다. 너무 작아지면 마지막 결과를 쓴다.
    side = (side * 0.8).floor();
    if (side < 320) {
      final bytes = Uint8List.fromList(
          img.encodeJpg(image, quality: PhotoLimits.minQuality));
      return CompressedPhoto(
          bytes: bytes, width: image.width, height: image.height, reencoded: true);
    }
    image = _fit(image, side);
  }
}

/// 긴 변이 [maxSide]를 넘으면 비율을 지켜 줄인다. 넘지 않으면 그대로(확대 없음).
img.Image _fit(img.Image image, int maxSide) {
  final longest = image.width > image.height ? image.width : image.height;
  if (longest <= maxSide) return image;
  final scale = maxSide / longest;
  return img.copyResize(
    image,
    width: (image.width * scale).round().clamp(1, maxSide),
    height: (image.height * scale).round().clamp(1, maxSide),
    interpolation: img.Interpolation.average,
  );
}
