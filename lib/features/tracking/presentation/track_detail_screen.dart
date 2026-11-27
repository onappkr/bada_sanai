import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/geo/geo_point.dart';
import '../../../core/geo/polyline_codec.dart';
import '../../../core/geo/projection.dart';
import '../../catch_log/presentation/date_format.dart';
import '../../point/application/point_providers.dart';
import '../application/tracking_providers.dart';
import '../domain/tracking_ports.dart';
import 'track_list_screen.dart' show formatDistance, formatDuration;
import 'track_plot.dart';

/// 저장된 경로 상세: 거리·시간과, 경로선·주변 포인트를 그린 그림.
class TrackDetailScreen extends ConsumerWidget {
  const TrackDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedTrackProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('경로'),
        actions: [
          if (async.value != null)
            IconButton(
              tooltip: '삭제',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (t) => t == null
            ? const Center(child: Text('삭제되었거나 없는 경로입니다.'))
            : _Body(track: t),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('경로를 삭제할까요?'),
        content: const Text('이 경로는 목록에서 사라져요. 이미 저장한 포인트는 그대로예요.'),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: const Text('취소')),
          FilledButton(onPressed: () => c.pop(true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(trackRepositoryProvider).discard(id);
    if (context.mounted) context.pop();
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.track});

  final SavedTrack track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final route = track.encodedPolyline.isEmpty
        ? const <GeoPoint>[]
        : PolylineCodec.decode(track.encodedPolyline);
    final points = ref.watch(pointsProvider).value ?? const [];
    final near = withinExpandedBounds(
      route,
      points,
      (p) => GeoPoint(p.lat, p.lng),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(formatDateTime(track.startedAt), style: text.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _Stat(label: '이동 거리', value: formatDistance(track.distanceM))),
            Expanded(child: _Stat(label: '걸린 시간', value: formatDuration(track.duration))),
          ],
        ),
        const SizedBox(height: 16),
        if (route.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('기록된 위치가 없어 경로를 그릴 수 없어요.', textAlign: TextAlign.center),
          )
        else
          AspectRatio(
            aspectRatio: 1,
            child: TrackPlot(
              route: route,
              markers: [
                for (final p in near)
                  PlotMarker(name: p.name, position: GeoPoint(p.lat, p.lng)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        const Text('초록 점은 출발, 빨강 점은 도착, 이름이 붙은 점은 내 포인트예요. '
            '지도 배경 없이 상대 위치만 보여 줘요.',
            style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: text.headlineSmall),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}
