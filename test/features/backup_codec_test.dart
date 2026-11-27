import 'dart:convert';

import 'package:bada_sanai/core/db/app_database.dart';
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

BackupSnapshot snapshot({
  List<Point>? points,
  List<CatchLog>? logs,
  List<CatchItem>? items,
}) =>
    BackupSnapshot(
      exportedAt: DateTime.utc(2026, 11, 27, 5, 5),
      points: points ?? [point()],
      logs: logs ?? [log()],
      items: items ?? [item()],
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
  String? exportedJson;
  String? toPick;

  @override
  Future<void> export(String filename, String json) async {
    exportedName = filename;
    exportedJson = json;
  }

  @override
  Future<String?> pick() async => toPick;
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
      expect(name, 'bada_sanai_backup_20261127_1405.json');
    });

    test('내보내기는 인코딩한 JSON을 게이트웨이에 넘긴다', () async {
      final gw = _FakeGateway();
      final snap = await exportBackup(_FakeRepo(snapshot()), gw);
      expect(snap.livePointCount, 1);
      expect(gw.exportedName, startsWith('bada_sanai_backup_'));
      expect(BackupCodec.decode(gw.exportedJson!).points.single.toJson(),
          point().toJson());
    });

    test('복원: 취소하면 null, 정상 파일이면 저장소에 넘긴다', () async {
      final repo = _FakeRepo(snapshot());
      final gw = _FakeGateway();
      expect(await restoreBackup(repo, gw), isNull);
      expect(repo.restored, isNull);

      gw.toPick = BackupCodec.encode(snapshot());
      final r = await restoreBackup(repo, gw);
      expect(r!.added, 1);
      expect(repo.restored!.logs.single.toJson(), log().toJson());
    });

    test('복원: 이상한 파일이면 저장소를 건드리지 않고 예외', () async {
      final repo = _FakeRepo(snapshot());
      final gw = _FakeGateway()..toPick = '{"app":"bada_sanai","version":1}';
      await expectLater(restoreBackup(repo, gw), throwsFormatException);
      expect(repo.restored, isNull);
    });
  });
}
