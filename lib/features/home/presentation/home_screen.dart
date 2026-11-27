import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../catch_log/application/catch_log_providers.dart';
import '../../catch_log/domain/catch_log_models.dart';
import '../../catch_log/presentation/date_format.dart';
import '../../point/application/point_providers.dart';
import '../../species/domain/species_catalog.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/domain/track_recorder.dart';

/// 홈에 보여 줄 최근 일지 개수.
const homeRecentLogCount = 3;

/// 최근 일지(낚시한 시각 내림차순 상위 [homeRecentLogCount]건).
final recentCatchLogsProvider = StreamProvider.autoDispose<List<CatchLogView>>((ref) {
  return ref
      .watch(catchLogRepositoryProvider)
      .watchAll()
      .map((all) => all.take(homeRecentLogCount).toList());
});

/// S03 홈: 경로 기록 시작·이어 가기, 최근 일지, 내 포인트 수.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorder = ref.watch(trackingProvider);
    final logs = ref.watch(recentCatchLogsProvider);
    final pointCount = ref.watch(pointsProvider).value?.length;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('바다 사나이')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RecordCard(state: recorder),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.push(Routes.logNew),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('일지 쓰기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.go(Routes.map),
                  icon: const Icon(Icons.place_outlined),
                  label: Text(pointCount == null ? '내 포인트' : '내 포인트 $pointCount'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('최근 일지', style: text.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(Routes.logs),
                child: const Text('전체 보기'),
              ),
            ],
          ),
          logs.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('불러오지 못했습니다: $e'),
            data: (items) => items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('아직 기록이 없어요. 첫 조행기를 남겨 보세요.'),
                  )
                : Column(children: [for (final l in items) _LogTile(log: l)]),
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.waves),
              title: Text('물때·날씨·추천 어종'),
              subtitle: Text('오늘의 물때와 날씨, 이 시기에 잘 나오는 어종을 곧 보여 드릴게요.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends ConsumerWidget {
  const _RecordCard({required this.state});

  final RecorderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    if (state.active) {
      final paused = state.phase == RecorderPhase.paused;
      return Card(
        color: colors.primaryContainer,
        child: ListTile(
          leading: Icon(paused ? Icons.pause_circle : Icons.fiber_manual_record,
              color: paused ? null : Colors.red),
          title: Text(paused ? '경로 기록 일시정지 중' : '경로를 기록하고 있어요'),
          subtitle: Text('${_distance(state.distanceM)} · ${_elapsed(state.elapsed)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(Routes.tracking),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.route),
        title: const Text('경로 기록 시작'),
        subtitle: const Text('이동 경로를 남기고 오래 머문 자리를 포인트로 만들어요'),
        trailing: const Icon(Icons.chevron_right),
        // 직접 시작하는 경우라 도착 알림 화면(S10)을 거치지 않는다.
        onTap: () async {
          await ref.read(trackingProvider.notifier).start();
          if (context.mounted) context.push(Routes.tracking);
        },
      ),
    );
  }

  static String _distance(double m) =>
      m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(2)} km';

  static String _elapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '$h시간 $m분' : '$m분';
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final CatchLogView log;

  @override
  Widget build(BuildContext context) {
    final species = log.items.map((e) => speciesLabel(e.speciesCode)).toSet();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${log.genre.label} · ${formatDateTime(log.fishedAt)}'),
      subtitle: Text(
        log.items.isEmpty ? '조과 없음' : '${species.join(', ')} · 총 ${log.totalCount}마리',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(Routes.logDetailOf(log.id)),
    );
  }
}
