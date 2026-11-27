import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/team_providers.dart';
import 'team_widgets.dart';

/// 팀 목록. 함께 낚시 다니는 사람들과 출조 비용을 정산한다.
class TeamListScreen extends ConsumerWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('팀·정산')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTeam(context, ref),
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('팀 만들기'),
      ),
      body: teams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (items) => ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('함께 낚시한 사람들을 팀으로 묶고, 출조마다 쓴 비용을 n분의 1로 나눠 '
                  '누가 누구에게 얼마를 보낼지 계산해 드려요.\n'
                  '지금은 이 기기에서 한 사람(총무)이 이름으로 정리하는 방식이에요. '
                  '팀원이 각자 앱으로 참여하는 기능은 서버가 생기면 더해져요.'),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('아직 팀이 없어요.')),
              ),
            for (final t in items)
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(t.name),
                subtitle: Text('멤버 ${t.activeMembers.length}명'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.teamOf(t.id)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTeam(BuildContext context, WidgetRef ref) async {
    final name = await askText(context, title: '새 팀', label: '팀 이름', hint: '예: 주말 바다팀');
    if (name == null) return;
    try {
      final id = await ref.read(teamRepositoryProvider).createTeam(name);
      if (context.mounted) context.push(Routes.teamOf(id));
    } on ArgumentError catch (e) {
      if (context.mounted) toast(context, '${e.message}');
    }
  }
}
