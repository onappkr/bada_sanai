import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../catch_log/presentation/date_format.dart';
import '../application/tracking_providers.dart';
import '../domain/tracking_ports.dart';

String formatDistance(double m) =>
    m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(2)} km';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return h > 0 ? '$h시간 $m분' : '$m분';
}

/// 저장된 경로 목록.
class TrackListScreen extends ConsumerWidget {
  const TrackListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedTracksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('내 경로')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (tracks) => tracks.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('저장된 경로가 없어요.\n홈에서 경로 기록을 시작해 보세요.',
                      textAlign: TextAlign.center),
                ),
              )
            : ListView.separated(
                itemCount: tracks.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _TrackTile(track: tracks[i]),
              ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  const _TrackTile({required this.track});

  final SavedTrack track;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.route),
      title: Text(formatDateTime(track.startedAt)),
      subtitle: Text('${formatDistance(track.distanceM)} · ${formatDuration(track.duration)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.trackDetailOf(track.id)),
    );
  }
}
