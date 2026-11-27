import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/team_providers.dart';
import '../domain/settlement.dart';
import '../domain/settlement_summary.dart';
import '../domain/team_models.dart';
import 'team_widgets.dart';

/// 출조 상세: 비용 목록과 정산 결과(누가 누구에게 얼마).
class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(id));
    final expenses = ref.watch(expensesProvider(id));
    final teamId = trip.value?.teamId;
    final team = teamId == null ? null : ref.watch(teamProvider(teamId));

    if (trip.isLoading || expenses.isLoading || (team?.isLoading ?? false)) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final tv = trip.value, t = team?.value, list = expenses.value;
    if (tv == null || t == null || list == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('없는 출조입니다.')));
    }

    SettlementResult? result;
    String? problem;
    try {
      result = settleTrip(team: t, trip: tv, expenses: list);
    } on SettlementError catch (e) {
      problem = '정산을 계산하지 못했어요(${e.code}). 비용을 확인해 주세요.';
    }
    final repo = ref.read(teamRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tv.title),
        actions: [
          if (!tv.settled)
            IconButton(
              tooltip: '출조 수정',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(Routes.tripEditOf(tv.id)),
            ),
          IconButton(
            tooltip: '출조 삭제',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await confirm(context, '출조를 삭제할까요?', '비용 기록도 함께 목록에서 사라져요.', ok: '삭제');
              if (!ok) return;
              await repo.deleteTrip(tv.id);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      floatingActionButton: tv.settled
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(Routes.expenseNewOf(tv.id)),
              icon: const Icon(Icons.add),
              label: const Text('비용 추가'),
            ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: Text(t.name),
            subtitle: Text('${_date(tv.date)} · 참여 ${tv.participantIds.map(t.nameOf).join(', ')}'),
          ),
          if (tv.settled)
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('정산이 마감됐어요'),
              subtitle: Text('비용을 고치려면 아래에서 다시 열어 주세요.'),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('비용', style: Theme.of(context).textTheme.titleSmall),
          ),
          if (list.isEmpty)
            const ListTile(title: Text('아직 비용이 없어요. 기름값·미끼값·밥값 등을 적어 보세요.')),
          for (final e in list)
            ListTile(
              title: Text(e.description),
              subtitle: Text('${t.nameOf(e.payerId)} 결제 · ${e.targetIds.length == tv.participantIds.length ? '전원' : e.targetIds.map(t.nameOf).join(', ')}'),
              trailing: Text(won(e.amount), style: Theme.of(context).textTheme.titleSmall),
              onTap: tv.settled ? null : () => context.push(Routes.expenseEditOf(tv.id, e.id)),
            ),
          const Divider(),
          if (problem != null) ListTile(title: Text(problem)),
          if (result != null) _SettlementCard(team: t, trip: tv, result: result),
          if (result != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.ios_share),
                    label: const Text('정산 안내 보내기'),
                    onPressed: () => ref.read(textSharerProvider)(
                      settlementShareText(team: t, trip: tv, result: result!),
                      subject: '${tv.title} 정산',
                    ),
                  ),
                  tv.settled
                      ? OutlinedButton.icon(
                          icon: const Icon(Icons.lock_open),
                          label: const Text('다시 열기'),
                          onPressed: () => repo.setSettled(tv.id, false),
                        )
                      : FilledButton.icon(
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('정산 마감'),
                          onPressed: () async {
                            final ok = await confirm(context, '정산을 마감할까요?', '마감하면 비용을 고칠 수 없어요. 필요하면 다시 열 수 있어요.', ok: '마감');
                            if (ok) await repo.setSettled(tv.id, true);
                          },
                        ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _date(DateTime d) {
    final l = d.toLocal();
    return '${l.year}.${l.month.toString().padLeft(2, '0')}.${l.day.toString().padLeft(2, '0')}';
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({required this.team, required this.trip, required this.result});

  final TeamView team;
  final TripView trip;
  final SettlementResult result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정산 결과', style: text.titleMedium),
            const SizedBox(height: 4),
            Text('총 ${won(result.total)} · 한 사람당 약 ${won((result.total / trip.participantIds.length).round())}'),
            const SizedBox(height: 12),
            for (final i in result.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text(team.nameOf(i.userId))),
                    Text('부담 ${won(i.shareTotal)} · 결제 ${won(i.paidTotal)}', style: text.bodySmall),
                  ],
                ),
              ),
            const Divider(height: 24),
            Text('보낼 돈', style: text.titleSmall),
            const SizedBox(height: 4),
            if (result.transfers.isEmpty)
              const Text('주고받을 돈이 없어요.')
            else
              for (final t in result.transfers)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${team.nameOf(t.from)} → ${team.nameOf(t.to)}  ${won(t.amount)}'),
                ),
          ],
        ),
      ),
    );
  }
}
