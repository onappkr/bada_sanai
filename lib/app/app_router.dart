import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/catch_log/presentation/catch_log_detail_screen.dart';
import '../features/catch_log/presentation/catch_log_form_screen.dart';
import '../features/catch_log/presentation/catch_log_list_screen.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/forecast/presentation/forecast_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/permissions/presentation/permissions_screen.dart';
import '../features/tracking/presentation/arrival_screen.dart';
import '../features/tracking/presentation/candidates_screen.dart';
import '../features/tracking/presentation/track_detail_screen.dart';
import '../features/tracking/presentation/track_list_screen.dart';
import '../features/tracking/presentation/tracking_screen.dart';
import '../features/settings/presentation/onboarding_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/share/presentation/share_sheet_screen.dart';
import '../features/species/presentation/species_screen.dart';
import '../features/share/presentation/shared_point_screen.dart';
import '../features/point/presentation/point_detail_screen.dart';
import '../features/point/presentation/point_form_screen.dart';
import '../features/point/presentation/point_list_screen.dart';
import '../features/point/presentation/point_map_screen.dart';
import '../features/team/presentation/expense_form_screen.dart';
import '../features/team/presentation/team_detail_screen.dart';
import '../features/team/presentation/team_list_screen.dart';
import '../features/team/presentation/trip_detail_screen.dart';
import '../features/team/presentation/trip_form_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import 'onboarding_redirect.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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
                builder: (c, s) => const HomeScreen(),
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
                builder: (c, s) => const PointMapScreen(),
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
          path: Routes.pointList,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const PointListScreen(),
        ),
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
          path: Routes.teams,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const TeamListScreen(),
        ),
        GoRoute(
          path: Routes.team,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => TeamDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.tripNew,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => TripFormScreen.create(teamId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.trip,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => TripDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.tripEdit,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => TripFormScreen.edit(tripId: s.pathParameters['id']!),
        ),
        // '/expenses/new'는 '/expenses/:expenseId'보다 먼저 선언한다.
        GoRoute(
          path: Routes.expenseNew,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => ExpenseFormScreen(tripId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.expenseEdit,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => ExpenseFormScreen(
              tripId: s.pathParameters['id']!, expenseId: s.pathParameters['expenseId']),
        ),
        GoRoute(
          path: Routes.arrival,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const ArrivalScreen(),
        ),
        GoRoute(
          path: Routes.tracking,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const TrackingScreen(),
        ),
        GoRoute(
          path: Routes.candidates,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => CandidatesScreen(trackId: s.pathParameters['trackId']!),
        ),
        GoRoute(
          path: Routes.tracks,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const TrackListScreen(),
        ),
        GoRoute(
          path: Routes.trackDetail,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => TrackDetailScreen(id: s.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.species,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const SpeciesScreen(),
        ),
        GoRoute(
          path: Routes.insights,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const InsightsScreen(),
        ),
        GoRoute(
          path: Routes.forecast,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => const ForecastScreen(),
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
