import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../species/domain/species_catalog.dart';
import '../application/catch_log_providers.dart';
import '../domain/catch_log_models.dart';
import 'date_format.dart';

/// S06 일지 상세.
class CatchLogDetailScreen extends ConsumerWidget {
  const CatchLogDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(catchLogProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('일지'),
        actions: [
          if (async.value != null) ...[
            IconButton(
              tooltip: '수정',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(Routes.logEditOf(id)),
            ),
            IconButton(
              tooltip: '삭제',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (log) => log == null
            ? const Center(child: Text('삭제되었거나 없는 일지입니다.'))
            : _Body(log: log),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('일지를 삭제할까요?'),
        content: const Text('삭제한 일지는 목록에서 사라집니다.'),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: const Text('취소')),
          FilledButton(onPressed: () => c.pop(true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(catchLogRepositoryProvider).delete(id);
    if (context.mounted) context.pop();
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.log});

  final CatchLogView log;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(log.genre.label, style: text.headlineSmall),
        Text(formatDateTime(log.fishedAt), style: text.bodyMedium),
        const SizedBox(height: 16),
        Text('조과', style: text.titleMedium),
        if (log.items.isEmpty) const Text('기록된 조과가 없습니다.'),
        for (final it in log.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(speciesLabel(it.speciesCode)),
            subtitle: Text([
              if (it.lengthCm != null) '${it.lengthCm} cm',
              '${it.count}마리',
              if (it.memo != null) it.memo!,
            ].join(' · ')),
          ),
        const SizedBox(height: 16),
        if (log.genreDetail.isNotEmpty) ...[
          Text('상세', style: text.titleMedium),
          for (final f in log.genre.fields)
            if (log.genreDetail[f.key] != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(f.label),
                subtitle: Text(log.genreDetail[f.key]!),
              ),
          const SizedBox(height: 16),
        ],
        if (log.memo != null) ...[
          Text('메모', style: text.titleMedium),
          Text(log.memo!),
        ],
      ],
    );
  }
}
