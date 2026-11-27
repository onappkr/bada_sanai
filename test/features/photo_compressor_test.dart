import 'dart:math';
import 'dart:typed_data';

import 'package:bada_sanai/features/photo/domain/photo_compressor.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

/// 압축이 잘 안 되는(무작위 잡음) 사진. 실제 사진처럼 용량이 크다.
Uint8List noisyJpeg(int w, int h, {int quality = 95, int? orientation}) {
  final rnd = Random(1);
  final image = img.Image(width: w, height: h);
  for (final p in image) {
    p
      ..r = rnd.nextInt(256)
      ..g = rnd.nextInt(256)
      ..b = rnd.nextInt(256);
  }
  if (orientation != null) image.exif.imageIfd.orientation = orientation;
  return Uint8List.fromList(img.encodeJpg(image, quality: quality));
}

/// 단색(아주 잘 압축되는) 사진.
Uint8List flatPng(int w, int h) {
  final image = img.Image(width: w, height: h);
  img.fill(image, color: img.ColorRgb8(30, 120, 200));
  return Uint8List.fromList(img.encodePng(image));
}

int longest(CompressedPhoto c) => max(c.width, c.height);

void main() {
  test('큰 사진은 긴 변 1280px 이하·400KB 이하로 줄고 다시 읽힌다', () {
    final original = noisyJpeg(3000, 2000);
    expect(original.length, greaterThan(PhotoLimits.maxBytes)); // 전제: 원본이 규격을 넘는다

    final r = compressPhoto(original);
    expect(r.reencoded, isTrue);
    expect(longest(r), lessThanOrEqualTo(PhotoLimits.maxSidePx));
    expect(r.bytes.length, lessThanOrEqualTo(PhotoLimits.maxBytes));

    final back = img.decodeJpg(r.bytes)!;
    expect(back.width, r.width);
    expect(back.height, r.height);
  });

  test('가로세로 비율을 유지한다', () {
    final r = compressPhoto(noisyJpeg(3000, 2000));
    expect(r.width / r.height, closeTo(3000 / 2000, 0.01));
  });

  test('세로 사진도 긴 변(세로)이 1280px 이하', () {
    final r = compressPhoto(noisyJpeg(1500, 2400));
    expect(r.height, lessThanOrEqualTo(PhotoLimits.maxSidePx));
    expect(r.width, lessThan(r.height));
  });

  test('작은 사진은 확대하지 않는다', () {
    final r = compressPhoto(flatPng(400, 300));
    expect(r.width, 400);
    expect(r.height, 300);
    expect(r.bytes.length, lessThanOrEqualTo(PhotoLimits.maxBytes));
  });

  test('이미 규격에 맞는 사진도 JPEG로 다시 만들어 규격을 지킨다', () {
    final r = compressPhoto(noisyJpeg(200, 200, quality: 60));
    expect(r.reencoded, isTrue);
    expect(r.bytes.length, lessThanOrEqualTo(PhotoLimits.maxBytes));
  });

  test('PNG 입력도 읽어 JPEG로 바꾼다', () {
    final r = compressPhoto(flatPng(2000, 1000));
    expect(longest(r), PhotoLimits.maxSidePx);
    expect(img.decodeJpg(r.bytes), isNotNull);
  });

  test('EXIF 회전(6 = 시계방향 90도)을 픽셀에 반영해 가로세로가 바뀐다', () {
    // 저장된 픽셀은 가로 1600×900, EXIF는 90도 회전 → 화면에서는 세로 사진.
    final r = compressPhoto(noisyJpeg(1600, 900, orientation: 6));
    expect(r.width, lessThan(r.height));
    expect(r.height, lessThanOrEqualTo(PhotoLimits.maxSidePx));
  });

  test('용량 기준이 아주 빡빡하면 크기까지 줄여서 맞춘다', () {
    final r = compressPhoto(noisyJpeg(1200, 800), maxBytes: 30 * 1024);
    expect(r.bytes.length, lessThanOrEqualTo(30 * 1024));
    expect(longest(r), lessThan(1200));
  });

  test('읽을 수 없는 데이터는 원본을 그대로 돌려준다(reencoded=false)', () {
    final garbage = Uint8List.fromList(List.generate(500, (i) => i % 251));
    final r = compressPhoto(garbage);
    expect(r.reencoded, isFalse);
    expect(r.bytes, same(garbage));
  });

  test('빈 데이터도 죽지 않는다', () {
    final empty = Uint8List(0);
    final r = compressPhoto(empty);
    expect(r.reencoded, isFalse);
    expect(r.bytes, same(empty));
  });
}
