import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'features/catch_log/application/catch_log_providers.dart';
import 'features/catch_log/data/in_memory_catch_log_repository.dart';
import 'features/catch_log/domain/catch_log_models.dart';

/// 화면 미리보기용 진입점. SQLite 없이 메모리 저장소와 샘플 데이터로 실행한다.
///   flutter run -d chrome -t lib/main_preview.dart
Future<void> main() async {
  final repo = InMemoryCatchLogRepository();
  final now = DateTime.now();
  await repo.create(CatchLogInput(
    genre: Genre.lure,
    fishedAt: now.subtract(const Duration(days: 2)),
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

  runApp(ProviderScope(
    overrides: [
      catchLogRepositoryProvider.overrideWithValue(repo),
    ],
    child: const BadaSanaiApp(),
  ));
}
