import 'dart:convert';
import 'dart:typed_data';

import 'backup_archive.dart';
import 'backup_codec.dart';
import 'backup_models.dart';
import 'backup_ports.dart';

/// "bada_sanai_backup_20261127_1405.zip"
String backupFilename(DateTime t, {String extension = 'zip'}) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'bada_sanai_backup_${l.year}${two(l.month)}${two(l.day)}_${two(l.hour)}${two(l.minute)}.$extension';
}

/// 기록(JSON)과 사진 파일을 zip 하나로 묶어 내보낸다. 파일이 사라진 사진은 건너뛴다.
Future<BackupSnapshot> exportBackup(
  BackupRepository repo,
  BackupFileGateway gateway, {
  BackupPhotoFiles? photoFiles,
}) async {
  final snap = await repo.snapshot();
  final files = <String, Uint8List>{};
  final readable = <String>{};
  if (photoFiles != null) {
    for (final ph in snap.photos) {
      if (files.containsKey(ph.filePath) || !BackupArchive.isSafePhotoPath(ph.filePath)) continue;
      final bytes = await photoFiles.read(ph.filePath);
      if (bytes != null) files[ph.filePath] = bytes;
    }
    readable.addAll(files.keys);
  }
  // 파일을 읽지 못한 사진은 기록에서도 뺀다(복원했을 때 빈 사진이 남지 않게).
  final exported = BackupSnapshot(
    exportedAt: snap.exportedAt,
    points: snap.points,
    logs: snap.logs,
    items: snap.items,
    photos: [for (final ph in snap.photos) if (readable.contains(ph.filePath)) ph],
  );
  final zip = BackupArchive.pack(BackupCodec.encode(exported), files);
  await gateway.export(backupFilename(snap.exportedAt), zip, 'application/zip');
  return exported;
}

/// 파일을 고르게 해 병합 복원한다. 취소하면 null, 파일이 이상하면 [FormatException].
/// zip(사진 포함)과 예전 JSON(v1) 파일을 모두 받는다.
Future<RestoreResult?> restoreBackup(
  BackupRepository repo,
  BackupFileGateway gateway, {
  BackupPhotoFiles? photoFiles,
}) async {
  final bytes = await gateway.pick();
  if (bytes == null) return null;

  final String json;
  var photos = const <String, Uint8List>{};
  if (BackupArchive.isZip(bytes)) {
    final bundle = BackupArchive.unpack(bytes);
    json = bundle.json;
    photos = bundle.photos;
  } else {
    try {
      json = utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('글자 파일이 아닙니다');
    }
  }
  final decoded = BackupCodec.decode(json);

  // 파일이 꾸러미에 있는 사진만 연결한다. 이미 기기에 같은 파일이 있으면 그대로 둔다.
  final written = <String>[];
  final usable = <String>{};
  try {
    if (photoFiles != null) {
      for (final ph in decoded.photos) {
        final data = photos[ph.filePath];
        if (data != null) {
          if (await photoFiles.read(ph.filePath) == null) {
            await photoFiles.write(ph.filePath, data);
            written.add(ph.filePath);
          }
          usable.add(ph.filePath);
        } else if (await photoFiles.read(ph.filePath) != null) {
          usable.add(ph.filePath);
        }
      }
    }
    final snap = BackupSnapshot(
      exportedAt: decoded.exportedAt,
      points: decoded.points,
      logs: decoded.logs,
      items: decoded.items,
      photos: [for (final ph in decoded.photos) if (usable.contains(ph.filePath)) ph],
    );
    return await repo.restore(snap);
  } catch (_) {
    // 기록 복원이 실패하면 방금 쓴 사진 파일이 고아로 남지 않게 지운다.
    for (final path in written) {
      await photoFiles?.delete(path);
    }
    rethrow;
  }
}
