import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/catch_log/presentation/catch_log_detail_screen.dart';
import '../features/catch_log/presentation/catch_log_form_screen.dart';
import '../features/catch_log/presentation/catch_log_list_screen.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/permissions/presentation/permissions_screen.dart';
import '../features/settings/presentation/onboarding_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/share/presentation/share_sheet_screen.dart';
import '../features/share/presentation/shared_point_screen.dart';
import '../features/point/presentation/point_detail_screen.dart';
import '../features/point/presentation/point_form_screen.dart';
import '../features/point/presentation/point_list_screen.dart';
import '../shared/placeholder_screen.dart';
import 'onboarding_redirect.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

PlaceholderScreen _ph(
  String id,
  String title,
  String purpose, {
  Map<String, String> params = const {},
  List<Widget> actions = const [],
}) =>
    PlaceholderScreen(
      id: id,
      title: title,
      purpose: purpose,
      params: params,
      actions: actions,
    );

Widget _go(BuildContext c, String label, String path) =>
    FilledButton.tonal(onPressed: () => c.push(path), child: Text(label));

/// [onboardingDone]이 거짓이면 온보딩·권한 안내 외의 화면은 온보딩으로 보낸다.
/// 값이 바뀌면 [refresh]로 알려 다시 판단하게 한다.
GoRouter createRouter({
  String initialLocation = Routes.home,
  bool Function()? onboardingDone,
  Listenable? refresh,
}) =>
    GoRouter(
      navigatorKey: _rootKey,
      initialLocation: initialLocation,
      refreshListenable: refresh,
      redirect: onboardingDone == null
          ? null
          : (context, state) => onboardingRedirect(
                done: onboardingDone(),
                location: state.uri.toString(),
              ),
      routes: [
        // 탭 4개: 홈 / 일지 / 지도 / 설정
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => _Shell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.home,
                builder: (c, s) => Builder(
                  builder: (c) => _ph(
                    'S03',
                    '홈',
                    '오늘의 물때·날씨·수온, 추천 어종, 최근 일지, 경로 기록 시작',
                    actions: [
                      _go(c, '물때·날씨 상세 (S14)', Routes.forecast),
                      _go(c, '어종 추천 (S13)', Routes.species),
                      _go(c, '도착 알림 수락 (S10)', Routes.arrival),
                    ],
                  ),
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.logs,
                builder: (c, s) => const CatchLogListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootKey,
                    builder: (c, s) => const CatchLogFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootKey,
                    builder: (c, s) =>
                        CatchLogDetailScreen(id: s.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: _rootKey,
                        builder: (c, s) =>
                            CatchLogFormScreen(id: s.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.map,
                builder: (c, s) => const PointListScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.settings,
                builder: (c, s) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'backup',
                    parentNavigatorKey: _rootKey,
                    builder: (c, s) => const BackupScreen(),
                  ),
                ],
              ),
            ]),
          ],
        ),
        GoRoute(
          path: Routes.onboarding,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const OnboardingScreen(),
        ),
        GoRoute(
          path: Routes.permissions,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const PermissionsScreen(),
        ),
        // '/points/new'는 '/points/:id'보다 먼저 선언해야 한다.
        GoRoute(
          path: Routes.pointNew,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const PointFormScreen(),
        ),
        GoRoute(
          path: Routes.pointDetail,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => PointDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.pointEdit,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => PointFormScreen(id: s.pathParameters['id']),
        ),
        GoRoute(
          path: Routes.arrival,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => Builder(
            builder: (c) => _ph(
              'S10',
              '도착 알림 수락',
              '경로 기록을 시작할까요? 수락·나중에',
              actions: [_go(c, '수락 → 기록 시작', Routes.tracking)],
            ),
          ),
        ),
        GoRoute(
          path: Routes.tracking,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => Builder(
            builder: (c) => _ph(
              'S11',
              '경로 기록 중',
              '경과 시간, 이동 거리, 일시정지·종료',
              actions: [
                _go(c, '종료 → 후보 확정', Routes.candidatesOf('sample')),
              ],
            ),
          ),
        ),
        GoRoute(
          path: Routes.candidates,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => _ph(
            'S12',
            '포인트 후보 확정',
            '후보별 이름 입력·저장·버림',
            params: {'trackId': s.pathParameters['trackId']!},
          ),
        ),
        GoRoute(
          path: Routes.species,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => _ph('S13', '어종 추천', '현재 해역·날짜 기준 어종 순위'),
        ),
        GoRoute(
          path: Routes.forecast,
          parentNavigatorKey: _rootKey,
          builder: (c, s) =>
              _ph('S14', '물때·날씨 상세', '조위, 물때 단계, 파고·풍속·기온'),
        ),
        GoRoute(
          path: Routes.share,
          parentNavigatorKey: _rootKey,
          builder: (c, s) =>
              ShareSheetScreen(pointId: s.pathParameters['pointId']!),
        ),
        GoRoute(
          path: Routes.sharedPoint,
          parentNavigatorKey: _rootKey,
          // 앱 링크 자동 열기(딥링크)가 붙으면 https://도메인/p#조각 을 /p?f=조각 으로 바꿔 넘긴다.
          builder: (c, s) =>
              SharedPointScreen(fragment: s.uri.queryParameters['f']),
        ),
      ],
    );

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: '일지'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: '지도'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: '설정'),
        ],
      ),
    );
  }
}
