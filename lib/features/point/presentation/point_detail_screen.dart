import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/point_providers.dart';
import '../domain/point_models.dart';

/// S08 포인트 상세.
class PointDetailScreen extends ConsumerWidget {
  const PointDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pointProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트'),
        actions: [
          if (async.value != null) ...[
            IconButton(
              tooltip: '공유',
              icon: const Icon(Icons.share_outlined),
              onPressed: () => context.push(Routes.shareOf(id)),
            ),
            IconButton(
              tooltip: '편집',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(Routes.pointEditOf(id)),
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
        data: (p) => p == null
            ? const Center(child: Text('삭제되었거나 없는 포인트입니다.'))
            : _Body(point: p),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('포인트를 삭제할까요?'),
        content: const Text('삭제한 포인트는 목록에서 사라집니다.'),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: const Text('취소')),
          FilledButton(onPressed: () => c.pop(true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(pointRepositoryProvider).delete(id);
    if (context.mounted) context.pop();
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.point});

  final PointView point;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(point.name, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text([
          if (point.genre != null) point.genre!.label,
          point.source.label,
        ].join(' · ')),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.my_location),
          title: Text(
              '${point.lat.toStringAsFixed(5)}, ${point.lng.toStringAsFixed(5)}'),
          subtitle: const Text('위도, 경도'),
        ),
        if (point.memo != null) ...[
          const SizedBox(height: 8),
          Text('메모', style: text.titleMedium),
          Text(point.memo!),
        ],
      ],
    );
  }
}
