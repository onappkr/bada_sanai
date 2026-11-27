import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../species/domain/species_catalog.dart';
import '../application/catch_log_providers.dart';
import '../domain/catch_log_models.dart';
import 'date_format.dart';

/// S04 일지 목록.
class CatchLogListScreen extends ConsumerWidget {
  const CatchLogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(catchLogsProvider);
    final filter = ref.watch(genreFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('일지')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.logNew),
        icon: const Icon(Icons.add),
        label: const Text('기록하기'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('전체'),
                    selected: filter == null,
                    onSelected: (_) =>
                        ref.read(genreFilterProvider.notifier).select(null),
                  ),
                ),
                for (final g in Genre.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(g.label),
                      selected: filter == g,
                      onSelected: (_) =>
                          ref.read(genreFilterProvider.notifier).select(g),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: logs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('기록이 없습니다. 첫 조행기를 남겨 보세요.'))
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
