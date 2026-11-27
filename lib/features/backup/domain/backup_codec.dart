import 'dart:convert';

import '../../../core/db/app_database.dart' show CatchItem, CatchLog, Photo, Point;
import 'backup_archive.dart';
import 'backup_models.dart';

/// 백업 기록 형식(JSON). v2에서 `photos`(사진 메타데이터)가 늘었고, v1 파일도 읽는다.
/// 순수 Dart라 어디서나 테스트할 수 있다.
class BackupCodec {
  const BackupCodec._();

  static const app = 'bada_sanai';
  static const version = 2;

  static String encode(BackupSnapshot s) => const JsonEncoder.withIndent(' ').convert({
        'app': app,
        'version': version,
        'exportedAt': s.exportedAt.toUtc().toIso8601String(),
        'points': [for (final p in s.points) p.toJson()],
        'logs': [for (final l in s.logs) l.toJson()],
        'items': [for (final i in s.items) i.toJson()],
        'photos': [for (final p in s.photos) p.toJson()],
      });

  /// 읽을 수 없거나 앞뒤가 맞지 않으면 [FormatException]. 파일은 믿지 않고 검증한다.
  static BackupSnapshot decode(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const FormatException('백업 파일이 아닙니다(JSON이 아님)');
    }
    if (root is! Map<String, dynamic> || root['app'] != app) {
      throw const FormatException('바다 사나이 백업 파일이 아닙니다');
    }
    final v = root['version'];
    if (v is! int || v < 1) throw const FormatException('버전 정보가 올바르지 않습니다');
    if (v > version) {
      throw FormatException('더 새로운 앱에서 만든 백업입니다(v$v). 앱을 업데이트해 주세요');
    }

    try {
      final exportedAt = DateTime.parse(root['exportedAt'] as String);
      final points = _list(root['points'], Point.fromJson);
      final logs = _list(root['logs'], CatchLog.fromJson);
      final items = _list(root['items'], CatchItem.fromJson);
      // v1 파일에는 photos가 없다.
      final photos = root['photos'] == null ? <Photo>[] : _list(root['photos'], Photo.fromJson);
      _validate(points, logs, items, photos);
      return BackupSnapshot(
        exportedAt: exportedAt,
        points: points,
        logs: logs,
        items: items,
        photos: photos,
      );
    } on FormatException {
      rethrow;
    } on Object {
      // 필드 누락·형 불일치(TypeError 등)는 모두 손상된 파일로 본다.
      throw const FormatException('백업 파일의 내용이 손상되었습니다');
    }
  }

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) from) {
    if (raw is! List) throw const FormatException('백업 파일의 내용이 손상되었습니다');
    return [for (final e in raw) from(e as Map<String, dynamic>)];
  }

  static void _validate(
      List<Point> points, List<CatchLog> logs, List<CatchItem> items, List<Photo> photos) {
    void unique(Iterable<String> ids, String what) {
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) throw FormatException('$what id가 중복되었습니다');
      }
    }

    unique(points.map((e) => e.id), '포인트');
    unique(logs.map((e) => e.id), '일지');
    unique(items.map((e) => e.id), '조과');
    unique(photos.map((e) => e.id), '사진');

    for (final p in points) {
      if (p.name.trim().isEmpty ||
          p.lat < -90 ||
          p.lat > 90 ||
          p.lng < -180 ||
          p.lng > 180) {
        throw const FormatException('올바르지 않은 포인트가 들어 있습니다');
      }
    }
    final logIds = logs.map((e) => e.id).toSet();
    for (final i in items) {
      if (!logIds.contains(i.logId)) {
        throw const FormatException('일지 없이 남은 조과 기록이 있습니다');
      }
      if (i.count < 1) throw const FormatException('올바르지 않은 조과 기록이 있습니다');
    }
    for (final ph in photos) {
      if (!BackupArchive.isSafePhotoPath(ph.filePath)) {
        throw const FormatException('올바르지 않은 사진 경로가 들어 있습니다');
      }
    }
  }
}
