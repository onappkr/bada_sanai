import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/photo/application/photo_providers.dart';
import 'features/photo/data/file_photo_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 사진 표시는 동기로 파일 경로를 풀어야 하므로 시작할 때 저장 폴더를 확정한다.
  final photoStore = FilePhotoStore();
  await photoStore.prepare();

  runApp(ProviderScope(
    overrides: [photoStoreProvider.overrideWithValue(photoStore)],
    child: const BadaSanaiApp(),
  ));
}
