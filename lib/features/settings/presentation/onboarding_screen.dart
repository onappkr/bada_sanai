import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/settings_providers.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _Page(Icons.edit_note, '조행기를 남겨요',
      '루어·원투·찍낚시·보트 낚시를 장르별로 기록하고, 조과와 사진, 마음에 든 포인트를 함께 저장해요.'),
  _Page(Icons.notifications_active_outlined, '바다에 도착하면 알려 드려요',
      '해안에 도착하면 알림으로 물어보고, 수락하면 이동 경로와 머문 자리를 기록해 포인트 후보로 만들어 드려요.'),
  _Page(Icons.lock_outline, '내 기록은 내 기기에',
      '로그인 없이 시작해요. 기록은 이 기기에만 저장되니 설정에서 가끔 백업해 두세요. 포인트는 링크로 친구에게 보낼 수 있어요.'),
];

/// S01 온보딩: 앱 소개 3장. 처음 실행 때 한 번, 이후에는 설정에서 다시 볼 수 있다.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  /// 설정에서 다시 본 경우(이미 완료)에는 끝나면 돌아가고, 처음이면 권한 안내로 간다.
  late final bool _revisit = ref.read(onboardingDoneProvider);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_revisit) {
      if (mounted) context.pop();
      return;
    }
    await ref.read(onboardingDoneProvider.notifier).complete();
    if (mounted) context.go(Routes.permissions);
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (!last) TextButton(onPressed: _finish, child: const Text('건너뛰기')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final p = _pages[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(p.icon, size: 96, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 32),
                      Text(p.title, style: text.headlineSmall, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(p.body, style: text.bodyLarge, textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _pages.length; i++)
                Container(
                  margin: const EdgeInsets.all(4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: last
                    ? _finish
                    : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                child: Text(last ? (_revisit ? '닫기' : '시작하기') : '다음'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
