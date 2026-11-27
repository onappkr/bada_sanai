import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'app_router.dart';

final routerProvider = Provider<GoRouter>((ref) => createRouter());

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
