import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'features/backup/application/backup_providers.dart';
import 'features/backup/domain/backup_models.dart';
import 'features/backup/domain/backup_ports.dart';
import 'features/catch_log/application/catch_log_providers.dart';
import 'features/catch_log/data/in_memory_catch_log_repository.dart';
import 'features/catch_log/domain/catch_log_models.dart';
import 'features/permissions/application/permission_providers.dart';
import 'features/permissions/domain/permission_service.dart';
import 'features/photo/application/photo_providers.dart';
import 'features/photo/data/in_memory_photo.dart';
import 'features/point/application/point_providers.dart';
import 'features/settings/application/settings_providers.dart';
import 'features/species/application/species_providers.dart';
import 'features/species/domain/rule_book.dart';
import 'features/settings/domain/data_eraser.dart';
import 'features/settings/data/settings_repositories.dart';
import 'features/share/application/share_providers.dart';
import 'features/tracking/application/tracking_providers.dart';
import 'features/tracking/data/in_memory_tracking.dart';
import 'features/tracking/domain/track_logic.dart';
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

  // 앱이 도중에 꺼진 것처럼 끝나지 않은 기록을 하나 심어 둔다(홈의 복구 안내를 보려고).
  final tracks = InMemoryTrackRepository(points);
  final interruptedStart = now.subtract(const Duration(hours: 3));
  final interruptedId = await tracks.start(interruptedStart);
  for (var i = 0; i <= 12; i++) {
    await tracks.addSample(
      interruptedId,
      LocationSample(
        lat: 35.0779,
        lng: 129.0868,
        time: interruptedStart.add(Duration(minutes: i)),
        accuracyM: 8,
      ),
    );
  }

  // 저장된 경로 하나(영도 방파제 쪽을 걷다 머문 기록)를 미리 저장해 둔다.
  final savedStart = now.subtract(const Duration(days: 1, hours: 2));
  final savedId = await tracks.start(savedStart);
  final savedSamples = [
    for (var i = 0; i <= 25; i++)
      LocationSample(
        lat: 35.0762 + (i < 12 ? i * 0.0002 : 12 * 0.0002) + (i % 3) * 0.00002,
        lng: 129.0850 + (i < 12 ? i * 0.0001 : 12 * 0.0001 + (i - 12) * 0.00018),
        time: savedStart.add(Duration(minutes: i * 2)),
        accuracyM: 6,
      ),
  ];
  await tracks.finish(savedId, summarizeTrack(savedStart, savedSamples));

  final photoRepo = InMemoryPhotoRepository();
  final photoStore = InMemoryPhotoStore();
  // 데이터 모두 삭제를 시험할 수 있게 메모리 저장소를 실제로 비운다.
  final eraser = _PreviewEraser(() {
    repo.clear();
    points.clear();
    photoRepo.clear();
    tracks.clear();
  });

  // 미리보기용 예시 규칙 데이터. 실제 낚시 정보가 아니라 화면을 보기 위한 가짜 값이다.
  final month = now.month;
  int wrap(int m) => ((m - 1) % 12 + 12) % 12 + 1;
  final sampleBook = RuleBook.parse(
    speciesRuleJson: jsonEncode({
      'version': 1,
      'species': [
        {'code': 'PV-A', 'name_ko': '예시 어종 가'},
        {'code': 'PV-B', 'name_ko': '예시 어종 나'},
        {'code': 'PV-C', 'name_ko': '예시 어종 다'},
      ],
      'rules': [
        {
          'species': 'PV-A',
          'regions': ['PV-1'],
          'months': [wrap(month - 1), month, wrap(month + 1)],
          'peak_months': [month],
          'genres': ['lure'],
          'note': '미리보기용 예시 데이터',
        },
        {
          'species': 'PV-B',
          'regions': ['PV-1'],
          'months': [month],
          'peak_months': [],
          'genres': ['cast'],
        },
        {
          'species': 'PV-C',
          'regions': ['PV-1'],
          'months': [wrap(month + 6)], // 이번 달이 아님 → 추천에서 빠진다
          'peak_months': [],
          'genres': ['lure'],
        },
      ],
    }),
    regionJson: jsonEncode({
      'version': 1,
      'regions': [
        {
          'code': 'PV-1',
          'name_ko': '예시 해역',
          'center': {'lat': 35.0779, 'lng': 129.0868},
        },
      ],
    }),
  );

  runApp(ProviderScope(
    overrides: [
      catchLogRepositoryProvider.overrideWithValue(repo),
      pointRepositoryProvider.overrideWithValue(points),
      shareImportRepositoryProvider
          .overrideWithValue(InMemoryShareImportRepository(points)),
      // 온보딩부터 보려면: flutter build web -t lib/main_preview.dart --dart-define=PREVIEW_ONBOARDING=true
      initialOnboardingDoneProvider
          .overrideWithValue(!const bool.fromEnvironment('PREVIEW_ONBOARDING')),
      settingsRepositoryProvider.overrideWithValue(InMemorySettingsRepository()),
      permissionServiceProvider.overrideWithValue(_PreviewPermissionService()),
      trackRepositoryProvider.overrideWithValue(tracks),
      locationSourceProvider.overrideWithValue(SimulatedLocationSource()),
      ruleBookProvider.overrideWith((ref) => sampleBook),
      backupRepositoryProvider.overrideWithValue(_PreviewBackupRepository()),
      backupFileGatewayProvider.overrideWithValue(_PreviewBackupGateway()),
      photoRepositoryProvider.overrideWithValue(photoRepo),
      dataEraserProvider.overrideWithValue(eraser),
      photoStoreProvider.overrideWithValue(photoStore),
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

/// 미리보기용 권한 가짜: 위치는 허용 가능, 알림은 허용됨, 카메라는 설정에서만 바꿀 수 있는 상태.
class _PreviewPermissionService implements PermissionService {
  final _state = {
    AppPermission.location: PermissionState.denied,
    AppPermission.notification: PermissionState.granted,
    AppPermission.camera: PermissionState.blocked,
  };

  @override
  Future<PermissionState> status(AppPermission permission) async => _state[permission]!;

  @override
  Future<PermissionState> request(AppPermission permission) async =>
      _state[permission] = PermissionState.granted;

  @override
  Future<void> openSettings() async {}
}

/// 미리보기용 삭제기: 메모리 저장소를 비운다.
class _PreviewEraser implements DataEraser {
  _PreviewEraser(this._clear);

  final void Function() _clear;

  @override
  Future<void> eraseAll() async => _clear();
}
