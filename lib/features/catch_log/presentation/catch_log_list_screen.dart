import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../species/domain/species_catalog.dart';
import '../application/catch_log_providers.dart';
import '../domain/catch_log_models.dart';
import '../domain/log_period.dart';
import 'date_format.dart';

/// S04 일지 목록.
class CatchLogListScreen extends ConsumerWidget {
  const CatchLogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(catchLogsProvider);
    final filter = ref.watch(genreFilterProvider);
    final period = ref.watch(periodFilterProvider);
    final filtering = filter != null || period != LogPeriod.all;

    return Scaffold(
      appBar: AppBar(title: const Text('일지')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.logNew),
        icon: const Icon(Icons.add),
        label: const Text('기록하기'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 칩 줄은 Row가 아니라 Wrap으로 둔다. ChoiceChip을 폭 제한이 없는 Row에 넣으면
          // 글자가 한 글자 폭으로 잘려 보이는 문제가 있어(웹에서 확인) 줄바꿈되는 Wrap이 안전하다.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('전체'),
                  selected: filter == null,
                  onSelected: (_) =>
                      ref.read(genreFilterProvider.notifier).select(null),
                ),
                for (final g in Genre.values)
                  ChoiceChip(
                    label: Text(g.label),
                    selected: filter == g,
                    onSelected: (_) =>
                        ref.read(genreFilterProvider.notifier).select(g),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final p in LogPeriod.values)
                  ChoiceChip(
                    label: Text(p.label),
                    selected: period == p,
                    onSelected: (_) =>
                        ref.read(periodFilterProvider.notifier).select(p),
                  ),
              ],
            ),
          ),
          Expanded(
            child: logs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
              data: (items) => items.isEmpty
                  ? Center(
                      child: Text(filtering
                          ? '조건에 맞는 기록이 없습니다.'
                          : '기록이 없습니다. 첫 조행기를 남겨 보세요.'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => _LogTile(log: items[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final CatchLogView log;

  @override
  Widget build(BuildContext context) {
    final species = log.items.map((e) => speciesLabel(e.speciesCode)).toSet();
    final subtitle = log.items.isEmpty
        ? '조과 없음'
        : '${species.join(', ')} · 총 ${log.totalCount}마리';
    return ListTile(
      title: Text('${log.genre.label} · ${formatDateTime(log.fishedAt)}'),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.logDetailOf(log.id)),
    );
  }
}
