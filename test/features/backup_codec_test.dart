import 'dart:convert';
import 'dart:typed_data';

import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/backup/domain/backup_archive.dart';
import 'package:bada_sanai/features/backup/domain/backup_codec.dart';
import 'package:bada_sanai/features/backup/domain/backup_models.dart';
import 'package:bada_sanai/features/backup/domain/backup_ports.dart';
import 'package:bada_sanai/features/backup/domain/backup_service.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 1, 6);

Point point({String id = 'p1', String name = '방파제', double lat = 35.1, double lng = 129.0}) =>
    Point(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      genre: Genre.lure,
      memo: '메모',
      source: PointSource.manual,
      createdAt: t0,
      updatedAt: t0,
      deletedAt: null,
    );

CatchLog log({String id = 'l1', String? pointId = 'p1', DateTime? deletedAt}) => CatchLog(
      id: id,
      genre: Genre.cast,
      fishedAt: t0,
      pointId: pointId,
      lat: null,
      lng: null,
      memo: null,
      genreDetail: '{"bait":"청개비"}',
      env: '{}',
      createdAt: t0,
      updatedAt: t0,
      deletedAt: deletedAt,
    );

CatchItem item({String id = 'i1', String logId = 'l1', int count = 2}) => CatchItem(
      id: id,
      logId: logId,
      speciesCode: 'seabass',
      lengthCm: 55.5,
      count: count,
      memo: null,
    );

Photo photo({String id = 'ph1', String ownerId = 'l1', String path = 'photos/a.jpg'}) => Photo(
      id: id,
      ownerType: OwnerType.log,
      ownerId: ownerId,
      filePath: path,
      width: null,
      height: null,
      createdAt: t0,
    );

BackupSnapshot snapshot({
  List<Point>? points,
  List<CatchLog>? logs,
  List<CatchItem>? items,
  List<Photo>? photos,
}) =>
    BackupSnapshot(
      exportedAt: DateTime.utc(2026, 11, 27, 5, 5),
      points: points ?? [point()],
      logs: logs ?? [log()],
      items: items ?? [item()],
      photos: photos ?? const [],
    );

class _FakeRepo implements BackupRepository {
  _FakeRepo(this.snap);
  BackupSnapshot snap;
  BackupSnapshot? restored;

  @override
  Future<BackupSnapshot> snapshot() async => snap;

  @override
  Future<RestoreResult> restore(BackupSnapshot s) async {
    restored = s;
    return RestoreResult(added: s.points.length, updated: 0, skipped: 0);
  }
}

class _FakeGateway implements BackupFileGateway {
  String? exportedName;
  Uint8List? exportedBytes;
  Uint8List? toPick;

  /// 내보낸 zip에서 기록(JSON)만 꺼낸다.
  String get exportedJson => BackupArchive.unpack(exportedBytes!).json;

  @override
  Future<void> export(String filename, Uint8List bytes, String mimeType) async {
    exportedName = filename;
    exportedBytes = bytes;
  }

  @override
  Future<Uint8List?> pick() async => toPick;
}

Uint8List text(String s) => Uint8List.fromList(utf8.encode(s));

class _FakePhotoFiles implements BackupPhotoFiles {
  final Map<String, Uint8List> files = {};
  final List<String> deleted = [];

  @override
  Future<Uint8List?> read(String path) async => files[path];

  @override
  Future<void> write(String path, Uint8List bytes) async => files[path] = bytes;

  @override
  Future<void> delete(String path) async {
    deleted.add(path);
    files.remove(path);
  }
}

class _ThrowingRepo extends _FakeRepo {
  _ThrowingRepo(super.snap);

  @override
  Future<RestoreResult> restore(BackupSnapshot s) async => throw StateError('DB 오류');
}

void main() {
  group('BackupCodec 왕복', () {
    test('모든 필드가 그대로 돌아온다', () {
      final back = BackupCodec.decode(BackupCodec.encode(snapshot()));
      // 시각은 같은 순간이면 된다(복원 시 최신 여부는 순간으로 비교한다).
      expect(back.exportedAt.isAtSameMomentAs(DateTime.utc(2026, 11, 27, 5, 5)), isTrue);
      expect(back.points.single.toJson(), point().toJson());
      expect(back.logs.single.toJson(), log().toJson());
      expect(back.items.single.toJson(), item().toJson());
    });

    test('삭제 표시된 행도 보존된다', () {
      final deleted = log(deletedAt: DateTime.utc(2026, 11, 2));
      final back = BackupCodec.decode(BackupCodec.encode(snapshot(logs: [deleted])));
      expect(back.logs.single.deletedAt!.isAtSameMomentAs(DateTime.utc(2026, 11, 2)), isTrue);
      expect(back.liveLogCount, 0);
    });

    test('비어 있는 백업도 만들고 읽을 수 있다', () {
      final back = BackupCodec.decode(
          BackupCodec.encode(snapshot(points: [], logs: [], items: [])));
      expect(back.points, isEmpty);
    });
  });

  group('BackupCodec 검증: 이상한 파일은 FormatException', () {
    Map<String, dynamic> valid() =>
        jsonDecode(BackupCodec.encode(snapshot())) as Map<String, dynamic>;
    String enc(Map<String, dynamic> m) => jsonEncode(m);

    test('JSON이 아니거나 다른 앱의 파일', () {
      expect(() => BackupCodec.decode('안녕'), throwsFormatException);
      expect(() => BackupCodec.decode('[]'), throwsFormatException);
      expect(() => BackupCodec.decode(enc({...valid(), 'app': 'other'})),
          throwsFormatException);
    });

    test('버전이 없거나 더 새로운 버전', () {
      expect(() => BackupCodec.decode(enc({...valid(), 'version': 'x'})),
          throwsFormatException);
      expect(() => BackupCodec.decode(enc({...valid(), 'version': 99})),
          throwsFormatException);
    });

    test('필드가 빠지거나 형이 다르면 손상된 파일', () {
      final m = valid();
      (m['points'] as List).first.remove('name');
      expect(() => BackupCodec.decode(enc(m)), throwsFormatException);
      expect(() => BackupCodec.decode(enc({...valid(), 'logs': 'x'})),
          throwsFormatException);
      expect(() => BackupCodec.decode(enc({...valid(), 'exportedAt': 5})),
          throwsFormatException);
    });

    test('범위를 벗어난 좌표·빈 이름·중복 id·고아 조과·잘못된 마릿수', () {
      expect(
          () => BackupCodec.decode(
              BackupCodec.encode(snapshot(points: [point(lat: 95)]))),
          throwsFormatException);
      expect(
          () => BackupCodec.decode(
              BackupCodec.encode(snapshot(points: [point(name: ' ')]))),
          throwsFormatException);
      expect(
          () => BackupCodec.decode(
              BackupCodec.encode(snapshot(points: [point(), point()]))),
          throwsFormatException);
      expect(
          () => BackupCodec.decode(
              BackupCodec.encode(snapshot(items: [item(logId: 'none')]))),
          throwsFormatException);
      expect(
          () => BackupCodec.decode(
              BackupCodec.encode(snapshot(items: [item(count: 0)]))),
          throwsFormatException);
    });
  });

  group('내보내기·복원 흐름', () {
    test('파일명은 로컬 시각 기준 날짜·시각', () {
      final name = backupFilename(DateTime(2026, 11, 27, 14, 5));
      expect(name, 'bada_sanai_backup_20261127_1405.zip');
    });

    test('내보내기는 기록 JSON을 담은 zip을 게이트웨이에 넘긴다', () async {
      final gw = _FakeGateway();
      final snap = await exportBackup(_FakeRepo(snapshot()), gw);
      expect(snap.livePointCount, 1);
      expect(gw.exportedName, startsWith('bada_sanai_backup_'));
      expect(BackupCodec.decode(gw.exportedJson).points.single.toJson(),
          point().toJson());
    });

    test('복원: 취소하면 null, 정상 파일이면 저장소에 넘긴다', () async {
      final repo = _FakeRepo(snapshot());
      final gw = _FakeGateway();
      expect(await restoreBackup(repo, gw), isNull);
      expect(repo.restored, isNull);

      gw.toPick = text(BackupCodec.encode(snapshot()));
      final r = await restoreBackup(repo, gw);
      expect(r!.added, 1);
      expect(repo.restored!.logs.single.toJson(), log().toJson());
    });

    test('복원: 이상한 파일이면 저장소를 건드리지 않고 예외', () async {
      final repo = _FakeRepo(snapshot());
      final gw = _FakeGateway()..toPick = text('{"app":"bada_sanai","version":1}');
      await expectLater(restoreBackup(repo, gw), throwsFormatException);
      expect(repo.restored, isNull);
    });
  });

  group('사진 포함 백업', () {
    final jpg = Uint8List.fromList([0xFF, 0xD8, 1, 2, 3]);

    test('사진 메타데이터가 왕복한다', () {
      final back = BackupCodec.decode(BackupCodec.encode(snapshot(photos: [photo()])));
      expect(back.photos.single.toJson(), photo().toJson());
    });

    test('v1 파일(photos 없음)도 읽는다', () {
      final m = jsonDecode(BackupCodec.encode(snapshot())) as Map<String, dynamic>
        ..remove('photos')
        ..['version'] = 1;
      expect(BackupCodec.decode(jsonEncode(m)).photos, isEmpty);
    });

    test('위험한 사진 경로는 거부한다', () {
      for (final bad in ['../x.jpg', 'photos/../x.jpg', '/etc/passwd', 'photos/a/b.jpg', 'x.jpg', 'photos\\a.jpg', 'photos/']) {
        expect(() => BackupCodec.decode(BackupCodec.encode(snapshot(photos: [photo(path: bad)]))),
            throwsFormatException,
            reason: bad);
      }
    });

    test('같은 사진 id가 둘이면 거부한다', () {
      expect(() => BackupCodec.decode(BackupCodec.encode(snapshot(photos: [photo(), photo()]))),
          throwsFormatException);
    });

    test('zip 꾸러미 왕복: 기록과 사진 파일이 그대로 돌아온다', () {
      final zip = BackupArchive.pack('{"a":1}', {'photos/a.jpg': jpg});
      expect(BackupArchive.isZip(zip), isTrue);
      final b = BackupArchive.unpack(zip);
      expect(b.json, '{"a":1}');
      expect(b.photos['photos/a.jpg'], jpg);
    });

    test('zip: backup.json이 없거나 zip이 아니면 FormatException', () {
      expect(() => BackupArchive.unpack(text('PK엉터리')), throwsFormatException);
      expect(() => BackupArchive.unpack(Uint8List(0)), throwsFormatException);
    });

    test('zip: 경로를 벗어나는 항목은 무시한다', () {
      final zip = BackupArchive.pack('{}', {'photos/ok.jpg': jpg});
      final b = BackupArchive.unpack(zip);
      expect(b.photos.keys, ['photos/ok.jpg']);
      // pack 단계에서도 안전하지 않은 경로는 넣지 않는다.
      final bad = BackupArchive.unpack(BackupArchive.pack('{}', {'../evil.jpg': jpg, 'photos/a/b.jpg': jpg}));
      expect(bad.photos, isEmpty);
    });

    test('내보내기: 사진 파일을 zip에 담고, 파일이 없는 사진은 기록에서도 뺀다', () async {
      final files = _FakePhotoFiles()..files['photos/a.jpg'] = jpg;
      final repo = _FakeRepo(snapshot(photos: [photo(), photo(id: 'ph2', path: 'photos/gone.jpg')]));
      final gw = _FakeGateway();
      final snap = await exportBackup(repo, gw, photoFiles: files);
      expect(snap.photos.map((e) => e.id), ['ph1']);
      final b = BackupArchive.unpack(gw.exportedBytes!);
      expect(b.photos.keys, ['photos/a.jpg']);
      expect(BackupCodec.decode(b.json).photos.map((e) => e.id), ['ph1']);
    });

    test('복원: zip의 사진 파일을 기기에 쓰고 사진 기록을 넘긴다', () async {
      final repo = _FakeRepo(snapshot());
      final files = _FakePhotoFiles();
      final gw = _FakeGateway()
        ..toPick = BackupArchive.pack(
            BackupCodec.encode(snapshot(photos: [photo()])), {'photos/a.jpg': jpg});
      await restoreBackup(repo, gw, photoFiles: files);
      expect(files.files['photos/a.jpg'], jpg);
      expect(repo.restored!.photos.single.id, 'ph1');
    });

    test('복원: 파일이 꾸러미에도 기기에도 없는 사진은 연결하지 않는다', () async {
      final repo = _FakeRepo(snapshot());
      final gw = _FakeGateway()
        ..toPick = BackupArchive.pack(BackupCodec.encode(snapshot(photos: [photo()])), {});
      await restoreBackup(repo, gw, photoFiles: _FakePhotoFiles());
      expect(repo.restored!.photos, isEmpty);
    });

    test('복원: 기기에 이미 같은 파일이 있으면 덮어쓰지 않고 연결한다', () async {
      final repo = _FakeRepo(snapshot());
      final files = _FakePhotoFiles()..files['photos/a.jpg'] = Uint8List.fromList([9]);
      final gw = _FakeGateway()
        ..toPick = BackupArchive.pack(
            BackupCodec.encode(snapshot(photos: [photo()])), {'photos/a.jpg': jpg});
      await restoreBackup(repo, gw, photoFiles: files);
      expect(files.files['photos/a.jpg'], [9]);
      expect(repo.restored!.photos.single.id, 'ph1');
    });

    test('복원: 기록 복원이 실패하면 방금 쓴 사진 파일을 지운다', () async {
      final files = _FakePhotoFiles();
      final gw = _FakeGateway()
        ..toPick = BackupArchive.pack(
            BackupCodec.encode(snapshot(photos: [photo()])), {'photos/a.jpg': jpg});
      await expectLater(
          restoreBackup(_ThrowingRepo(snapshot()), gw, photoFiles: files), throwsStateError);
      expect(files.files, isEmpty);
      expect(files.deleted, ['photos/a.jpg']);
    });

    test('예전 JSON(v1) 백업 파일도 복원된다', () async {
      final m = jsonDecode(BackupCodec.encode(snapshot())) as Map<String, dynamic>
        ..remove('photos')
        ..['version'] = 1;
      final repo = _FakeRepo(snapshot());
      final gw = _FakeGateway()..toPick = text(jsonEncode(m));
      final r = await restoreBackup(repo, gw, photoFiles: _FakePhotoFiles());
      expect(r!.added, 1);
    });
  });
}
