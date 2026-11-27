import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// 백업 zip 꾸러미: `backup.json`(기록)과 `photos/…`(사진 파일). 순수 Dart.
class BackupBundle {
  const BackupBundle({required this.json, this.photos = const {}});

  final String json;

  /// 상대 경로(`photos/<이름>`) → 파일 내용.
  final Map<String, Uint8List> photos;
}

/// 백업 zip을 만들고 읽는다. 파일은 믿지 않고 검증한다(경로 탈출, 과대 용량).
class BackupArchive {
  const BackupArchive._();

  static const jsonName = 'backup.json';

  /// 압축을 푼 뒤 합계가 이 크기를 넘으면 거부한다(zip 폭탄 방어).
  static const maxUnpackedBytes = 500 * 1024 * 1024;
  static const maxEntries = 20000;

  /// zip 파일 머리말(PK)인지. JSON 백업(v1)과 구분한다.
  static bool isZip(Uint8List b) => b.length > 3 && b[0] == 0x50 && b[1] == 0x4B;

  /// 사진 상대 경로로 안전한가: `photos/` 아래의 한 단계 파일이고 `..`·역슬래시·절대 경로가 없다.
  static bool isSafePhotoPath(String path) {
    if (!path.startsWith('photos/')) return false;
    final name = path.substring('photos/'.length);
    return name.isNotEmpty &&
        !name.contains('/') &&
        !name.contains('\\') &&
        !name.contains('..') &&
        !name.contains('\u0000');
  }

  static Uint8List pack(String json, Map<String, Uint8List> photos) {
    final archive = Archive();
    final j = utf8.encode(json);
    archive.addFile(ArchiveFile(jsonName, j.length, j));
    for (final e in photos.entries) {
      if (!isSafePhotoPath(e.key)) continue;
      // 사진은 이미 압축된 JPEG라 다시 압축해도 이득이 없다.
      archive.addFile(ArchiveFile.noCompress(e.key, e.value.length, e.value));
    }
    final out = ZipEncoder().encode(archive);
    return Uint8List.fromList(out);
  }

  /// 읽을 수 없으면 [FormatException].
  static BackupBundle unpack(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const FormatException('백업 꾸러미(zip)를 열 수 없습니다');
    }
    if (archive.length > maxEntries) {
      throw const FormatException('백업 꾸러미의 파일이 너무 많습니다');
    }
    var total = 0;
    String? json;
    final photos = <String, Uint8List>{};
    for (final f in archive) {
      if (!f.isFile) continue;
      total += f.size;
      if (total > maxUnpackedBytes) {
        throw const FormatException('백업 꾸러미가 너무 큽니다');
      }
      if (f.name == jsonName) {
        try {
          json = utf8.decode(f.content as List<int>);
        } on FormatException {
          throw const FormatException('backup.json이 글자 파일이 아닙니다');
        }
      } else if (isSafePhotoPath(f.name)) {
        photos[f.name] = Uint8List.fromList(f.content as List<int>);
      }
      // 그 밖의 파일(이상한 경로 포함)은 무시한다.
    }
    if (json == null) throw const FormatException('백업 꾸러미에 backup.json이 없습니다');
    return BackupBundle(json: json, photos: photos);
  }
}
