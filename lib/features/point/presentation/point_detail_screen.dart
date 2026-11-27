import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../catch_log/application/catch_log_providers.dart';
import '../../catch_log/presentation/date_format.dart';
import '../../photo/application/photo_providers.dart';
import '../../photo/domain/photo_models.dart';
import '../../photo/presentation/photo_widgets.dart';
import '../../../core/geo/geo_point.dart';
import '../../species/domain/species_catalog.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/domain/track_visits.dart';
import '../../tracking/presentation/track_list_screen.dart' show formatDistance, formatDuration;
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

class _Body extends ConsumerWidget {
  const _Body({required this.point});

  final PointView point;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final logs = ref.watch(catchLogsByPointProvider(point.id)).value ?? const [];
    final photos = ref
            .watch(photosByOwnerProvider((type: OwnerType.point, id: point.id)))
            .value ??
        const [];
    final visits = tracksNearPoint(
      ref.watch(savedTracksProvider).value ?? const [],
      GeoPoint(point.lat, point.lng),
    );
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
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 16),
          PhotoStrip(photos: photos),
        ],
        const SizedBox(height: 16),
        Text('이 포인트의 일지 (${logs.length})', style: text.titleMedium),
        if (logs.isEmpty) const Text('연결된 일지가 없습니다.'),
        for (final l in logs)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${l.genre.label} · ${formatDateTime(l.fishedAt)}'),
            subtitle: Text(l.items.isEmpty
                ? '조과 없음'
                : '${l.items.map((e) => speciesLabel(e.speciesCode)).toSet().join(', ')}'
                    ' · 총 ${l.totalCount}마리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.logDetailOf(l.id)),
          ),
        const SizedBox(height: 16),
        Text('방문 경로 (${visits.length})', style: text.titleMedium),
        Text('이 포인트에서 ${visitRadiusM.round()}m 안을 지난 내 경로예요.',
            style: text.bodySmall),
        if (visits.isEmpty) const Text('아직 근처를 지난 경로가 없어요.'),
        for (final t in visits)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.route),
            title: Text(formatDateTime(t.startedAt)),
            subtitle: Text('${formatDistance(t.distanceM)} · ${formatDuration(t.duration)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.trackDetailOf(t.id)),
          ),
      ],
    );
  }
}
