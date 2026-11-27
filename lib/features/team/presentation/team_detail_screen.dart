import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/team_providers.dart';
import '../domain/settlement.dart';
import '../domain/team_models.dart';
import 'team_widgets.dart';

/// 팀 상세: 멤버, 끝전 규칙, 출조 목록.
class TeamDetailScreen extends ConsumerWidget {
  const TeamDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamProvider(id));
    final trips = ref.watch(tripsProvider(id));
    final repo = ref.read(teamRepositoryProvider);

    return team.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('불러오지 못했습니다: $e'))),
      data: (t) {
        if (t == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('없는 팀입니다.')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(t.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) => _menu(context, ref, t, v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('팀 이름 바꾸기')),
                  PopupMenuItem(value: 'delete', child: Text('팀 삭제')),
                ],
              ),
            ],
          ),
          floatingActionButton: t.activeMembers.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => context.push(Routes.tripNewOf(t.id)),
                  icon: const Icon(Icons.add),
                  label: const Text('출조 추가'),
                ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              _SectionTitle('멤버 ${t.activeMembers.length}명'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final m in t.activeMembers)
                      InputChip(
                        label: Text(m.name),
                        onDeleted: () => _removeMember(context, repo, m),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.person_add_alt_1, size: 18),
                      label: const Text('멤버 추가'),
                      onPressed: () => _addMember(context, repo, t.id),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _RuleTile(team: t),
              const Divider(),
              const _SectionTitle('출조'),
              if (t.activeMembers.isEmpty)
                const ListTile(title: Text('멤버를 먼저 추가해 주세요.'))
              else
                trips.when(
                  loading: () => const Padding(
                      padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => ListTile(title: Text('불러오지 못했습니다: $e')),
                  data: (list) => list.isEmpty
                      ? const ListTile(title: Text('아직 출조가 없어요. 출조를 추가하고 비용을 적어 보세요.'))
                      : Column(children: [
                          for (final trip in list)
                            ListTile(
                              leading: Icon(trip.settled ? Icons.check_circle : Icons.sailing_outlined),
                              title: Text(trip.title),
                              subtitle: Text(
                                  '${_date(trip.date)} · ${trip.participantIds.length}명${trip.settled ? ' · 정산 마감' : ''}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(Routes.tripOf(trip.id)),
                            ),
                        ]),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _date(DateTime d) {
    final l = d.toLocal();
    return '${l.year}.${l.month.toString().padLeft(2, '0')}.${l.day.toString().padLeft(2, '0')}';
  }

  Future<void> _menu(BuildContext context, WidgetRef ref, TeamView t, String v) async {
    final repo = ref.read(teamRepositoryProvider);
    if (v == 'rename') {
      final name = await askText(context, title: '팀 이름', label: '팀 이름', initial: t.name);
      if (name == null) return;
      try {
        await repo.renameTeam(t.id, name);
      } on ArgumentError catch (e) {
        if (context.mounted) toast(context, '${e.message}');
      }
    } else if (v == 'delete') {
      final ok = await confirm(context, '팀을 삭제할까요?', '출조와 비용 기록도 함께 목록에서 사라져요.', ok: '삭제');
      if (!ok) return;
      await repo.deleteTeam(t.id);
      if (context.mounted) context.pop();
    }
  }

  Future<void> _addMember(BuildContext context, repo, String teamId) async {
    final name = await askText(context, title: '멤버 추가', label: '이름', hint: '예: 김철수');
    if (name == null) return;
    try {
      await repo.addMember(teamId, name);
    } on ArgumentError catch (e) {
      if (context.mounted) toast(context, '${e.message}');
    }
  }

  Future<void> _removeMember(BuildContext context, repo, TeamMember m) async {
    final ok = await confirm(context, '${m.name}님을 팀에서 뺄까요?', '지난 출조의 비용 기록에는 이름이 그대로 남아요.', ok: '빼기');
    if (ok) await repo.removeMember(m.id);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}

/// 끝전 부담 규칙. 나누어떨어지지 않는 1~2원을 누가 낼지.
class _RuleTile extends ConsumerWidget {
  const _RuleTile({required this.team});

  final TeamView team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(teamRepositoryProvider);
    final isTreasurer = team.rule == RemainderRule.treasurer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('끝전 규칙'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<RemainderRule>(
            segments: const [
              ButtonSegment(value: RemainderRule.payer, label: Text('결제한 사람')),
              ButtonSegment(value: RemainderRule.treasurer, label: Text('총무')),
            ],
            selected: {team.rule},
            showSelectedIcon: false,
            onSelectionChanged: (s) async {
              final rule = s.first;
              if (rule == RemainderRule.payer) {
                await repo.setRule(team.id, rule);
              } else if (team.activeMembers.isNotEmpty) {
                await repo.setRule(team.id, rule, treasurerId: team.activeMembers.first.id);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            isTreasurer
                ? '10,000원을 3명이 나누는 것처럼 나누어떨어지지 않는 1~2원은 총무가 부담해요.'
                : '나누어떨어지지 않는 1~2원은 그 비용을 결제한 사람이 부담해요.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (isTreasurer && team.treasurerId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: DropdownButtonFormField<String>(
              initialValue: team.treasurerId,
              decoration: const InputDecoration(labelText: '총무'),
              items: [
                for (final m in team.activeMembers) DropdownMenuItem(value: m.id, child: Text(m.name)),
              ],
              onChanged: (v) {
                if (v != null) repo.setRule(team.id, RemainderRule.treasurer, treasurerId: v);
              },
            ),
          ),
      ],
    );
  }
}
