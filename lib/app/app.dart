import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/settings/application/settings_providers.dart';
import 'app_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // 온보딩 완료 여부가 바뀌면 라우터가 현재 위치를 다시 판단한다.
  final refresh = ValueNotifier<int>(0);
  ref.listen<bool>(onboardingDoneProvider, (_, _) => refresh.value++);
  final router = createRouter(
    onboardingDone: () => ref.read(onboardingDoneProvider),
    refresh: refresh,
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class BadaSanaiApp extends ConsumerWidget {
  const BadaSanaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '바다 사나이',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5FA5)),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
