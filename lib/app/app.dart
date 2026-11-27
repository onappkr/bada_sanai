import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'dart:async';

import '../features/arrival/application/arrival_providers.dart';
import '../features/arrival/domain/arrival_watcher.dart'
    show arrivalNotificationPayload;
import '../features/settings/application/settings_providers.dart';
import '../features/share/application/share_providers.dart';
import '../features/share/domain/deep_link.dart';
import 'app_router.dart';
import 'routes.dart';

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

/// 앱 전체에서 한 번만 듣는 이벤트: 도착 감시 복원, 알림 탭, 공유 링크(앱 링크).
class AppEvents extends ConsumerStatefulWidget {
  const AppEvents({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppEvents> createState() => _AppEventsState();
}

class _AppEventsState extends ConsumerState<AppEvents> {
  final _subs = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    // 첫 화면이 그려진 뒤에 시작한다(라우터가 준비된 다음에 이동해야 하므로).
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;
    final notifications = ref.read(notificationServiceProvider);
    try {
      await notifications.init();
      final launch = await notifications.launchPayload();
      if (launch != null) _onNotificationPayload(launch);
      _subs.add(notifications.taps.listen(_onNotificationPayload));
    } catch (_) {
      // 알림을 쓸 수 없는 환경이어도 앱의 나머지는 돌아가야 한다.
    }

    final links = ref.read(deepLinkServiceProvider);
    try {
      final initial = await links.initial();
      if (initial != null) _onLink(initial);
      _subs.add(links.stream.listen(_onLink));
    } catch (_) {
      // 링크를 받을 수 없는 환경.
    }

    unawaited(ref.read(arrivalControllerProvider.notifier).restore());
  }

  void _onNotificationPayload(String payload) {
    if (payload == arrivalNotificationPayload) {
      ref.read(routerProvider).push(Routes.arrival);
    }
  }

  void _onLink(Uri uri) {
    final fragment = sharedPointFragment(uri);
    if (fragment != null) {
      ref.read(routerProvider).push(Routes.sharedPointOf(fragment));
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class BadaSanaiApp extends ConsumerWidget {
  const BadaSanaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppEvents(
      child: MaterialApp.router(
        title: '바다 사나이',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B5FA5)),
          useMaterial3: true,
        ),
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
