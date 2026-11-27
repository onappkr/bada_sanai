import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/catch_log/presentation/catch_log_detail_screen.dart';
import '../features/catch_log/presentation/catch_log_form_screen.dart';
import '../features/catch_log/presentation/catch_log_list_screen.dart';
import '../shared/placeholder_screen.dart';
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

GoRouter createRouter({String initialLocation = Routes.home}) => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: initialLocation,
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
                builder: (c, s) => Builder(
                  builder: (c) => _ph(
                    'S07',
                    '포인트 지도',
                    '내 포인트 마커, 이동경로, 현재 위치',
                    actions: [
                      _go(c, '포인트 상세 예시 (S08)', Routes.pointDetailOf('sample')),
                      _go(c, '경로 기록 중 (S11)', Routes.tracking),
                    ],
                  ),
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.settings,
                builder: (c, s) => Builder(
                  builder: (c) => _ph(
                    'S17',
                    '설정',
                    '권한 상태, 알림, 단위, 약관, 버전',
                    actions: [
                      _go(c, '백업·복원 (S18)', Routes.backup),
                      _go(c, '권한 안내 (S02)', Routes.permissions),
                      _go(c, '온보딩 (S01)', Routes.onboarding),
                    ],
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'backup',
                    parentNavigatorKey: _rootKey,
                    builder: (c, s) => _ph(
                        'S18', '백업·복원', '파일 내보내기·불러오기, 클라우드 드라이브 백업'),
                  ),
                ],
              ),
            ]),
          ],
        ),
        GoRoute(
          path: Routes.onboarding,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => _ph('S01', '온보딩', '앱 소개 3장, 로그인 없이 시작'),
        ),
        GoRoute(
          path: Routes.permissions,
          parentNavigatorKey: _rootKey,
          builder: (c, s) =>
              _ph('S02', '권한 안내', '위치·알림·사진 권한을 이유와 함께 요청'),
        ),
        GoRoute(
          path: Routes.pointDetail,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => Builder(
            builder: (c) {
              final id = s.pathParameters['id']!;
              return _ph(
                'S08',
                '포인트 상세',
                '이름·메모·사진, 방문 이력, 공유·편집',
                params: {'id': id},
                actions: [
                  _go(c, '편집 (S09)', Routes.pointEditOf(id)),
                  _go(c, '공유 (S15)', Routes.shareOf(id)),
                ],
              );
            },
          ),
        ),
        GoRoute(
          path: Routes.pointEdit,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => _ph(
            'S09',
            '포인트 편집',
            '이름, 장르, 메모, 사진, 위치 미세 조정',
            params: {'id': s.pathParameters['id']!},
          ),
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
          builder: (c, s) => _ph(
            'S15',
            '공유 시트',
            '카카오톡·문자·링크 복사',
            params: {'pointId': s.pathParameters['pointId']!},
          ),
        ),
        GoRoute(
          path: Routes.sharedPoint,
          parentNavigatorKey: _rootKey,
          builder: (c, s) => _ph(
            'S16',
            '공유 받은 포인트',
            '지도 미리보기, 내 포인트에 저장',
            params: {'fragment': s.uri.fragment},
          ),
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
