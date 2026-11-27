import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/db/app_database.dart';
import 'features/catch_log/application/catch_log_providers.dart';
import 'features/photo/application/photo_providers.dart';
import 'features/photo/data/file_photo_store.dart';
import 'features/settings/application/settings_providers.dart';
import 'features/settings/data/settings_repositories.dart';
import 'features/settings/domain/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 사진 표시는 동기로 파일 경로를 풀어야 하므로 시작할 때 저장 폴더를 확정한다.
  final photoStore = FilePhotoStore();
  await photoStore.prepare();

  // 라우터가 첫 화면을 동기로 정해야 해서 온보딩 완료 여부를 먼저 읽는다.
  final db = AppDatabase(driftDatabase(name: 'bada_sanai'));
  var onboardingDone = false;
  try {
    onboardingDone = await DriftSettingsRepository(db).isOnboardingDone();
  } catch (_) {
    // 읽지 못하면 처음 실행처럼 온보딩부터 보여 준다.
  }

  runApp(ProviderScope(
    overrides: [
      photoStoreProvider.overrideWithValue(photoStore),
      databaseProvider.overrideWithValue(db),
      initialOnboardingDoneProvider.overrideWithValue(onboardingDone),
    ],
    child: const BadaSanaiApp(),
  ));
}
