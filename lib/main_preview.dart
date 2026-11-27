import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'features/backup/application/backup_providers.dart';
import 'features/backup/domain/backup_models.dart';
import 'features/backup/domain/backup_ports.dart';
import 'features/catch_log/application/catch_log_providers.dart';
import 'features/catch_log/data/in_memory_catch_log_repository.dart';
import 'features/catch_log/domain/catch_log_models.dart';
import 'features/photo/application/photo_providers.dart';
import 'features/photo/data/in_memory_photo.dart';
import 'features/point/application/point_providers.dart';
import 'features/share/application/share_providers.dart';
import 'features/share/data/in_memory_share_import_repository.dart';
import 'features/point/data/in_memory_point_repository.dart';
import 'features/point/domain/point_models.dart' show PointInput, PointSource;

/// 화면 미리보기용 진입점. SQLite 없이 메모리 저장소와 샘플 데이터로 실행한다.
///   flutter run -d chrome -t lib/main_preview.dart
Future<void> main() async {
  final repo = InMemoryCatchLogRepository();
  final now = DateTime.now();
  await repo.create(CatchLogInput(
    genre: Genre.lure,
    fishedAt: now.subtract(const Duration(days: 2)),
    pointId: 'pt-1',
    memo: '새벽 물돌이에 입질이 몰렸다. 바람 강함.',
    genreDetail: const {'lure': '지그헤드 20g, 화이트', 'rod': '9ft ML'},
    items: const [
      CatchItemInput(speciesCode: 'seabass', lengthCm: 62, count: 2),
      CatchItemInput(speciesCode: 'flatfish', lengthCm: 41, count: 1),
    ],
  ));
  await repo.create(CatchLogInput(
    genre: Genre.boat,
    fishedAt: now.subtract(const Duration(days: 9)),
    genreDetail: const {'boatName': '해돋이호'},
    items: const [CatchItemInput(speciesCode: 'rockfish', lengthCm: 30, count: 12)],
  ));
  await repo.create(CatchLogInput(
    genre: Genre.cast,
    fishedAt: now.subtract(const Duration(days: 20)),
    memo: '꽝',
  ));

  final points = InMemoryPointRepository();
  await points.create(const PointInput(
    name: '영도 방파제 끝',
    lat: 35.0779,
    lng: 129.0868,
    genre: Genre.lure,
    memo: '새벽 만조 전후로 농어가 붙는다. 주차는 입구 공터.',
  ));
  await points.create(const PointInput(
    name: '송정 갯바위',
    lat: 35.1786,
    lng: 129.2003,
    genre: Genre.cast,
  ));
  await points.create(const PointInput(
    name: '선배가 알려준 자리',
    lat: 35.1012,
    lng: 129.0301,
    source: PointSource.shared,
  ));

  runApp(ProviderScope(
    overrides: [
      catchLogRepositoryProvider.overrideWithValue(repo),
      pointRepositoryProvider.overrideWithValue(points),
      shareImportRepositoryProvider
          .overrideWithValue(InMemoryShareImportRepository(points)),
      backupRepositoryProvider.overrideWithValue(_PreviewBackupRepository()),
      backupFileGatewayProvider.overrideWithValue(_PreviewBackupGateway()),
      photoRepositoryProvider.overrideWithValue(InMemoryPhotoRepository()),
      photoStoreProvider.overrideWithValue(InMemoryPhotoStore()),
    ],
    child: const BadaSanaiApp(),
  ));
}

/// 미리보기용 백업 가짜. 실제 파일을 만들지 않고 결과 안내만 보여 준다.
class _PreviewBackupRepository implements BackupRepository {
  @override
  Future<BackupSnapshot> snapshot() async => BackupSnapshot(
      exportedAt: DateTime.now().toUtc(), points: const [], logs: const [], items: const []);

  @override
  Future<RestoreResult> restore(BackupSnapshot snapshot) async =>
      const RestoreResult(added: 3, updated: 1, skipped: 2);
}

class _PreviewBackupGateway implements BackupFileGateway {
  @override
  Future<void> export(String filename, String json) async {}

  @override
  Future<String?> pick() async =>
      '{"app":"bada_sanai","version":1,"exportedAt":"2026-11-27T00:00:00Z",'
      '"points":[],"logs":[],"items":[]}';
}
