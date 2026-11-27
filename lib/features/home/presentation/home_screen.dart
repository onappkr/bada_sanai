import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../catch_log/application/catch_log_providers.dart';
import '../../catch_log/domain/catch_log_models.dart';
import '../../catch_log/presentation/date_format.dart';
import '../../point/application/point_providers.dart';
import '../../species/application/species_providers.dart';
import '../../species/domain/species_catalog.dart';
import '../../species/domain/species_stats.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/domain/track_recorder.dart';
import '../../tracking/domain/track_recovery.dart';

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
          const _InterruptedBanner(),
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
          _SeasonCard(top: ref.watch(speciesRankingProvider).value),
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

/// 이 시기에 내가 잡은 어종 상위 3종 요약. 누르면 S13으로 간다.
class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.top});

  final List<SpeciesStat>? top;

  @override
  Widget build(BuildContext context) {
    final names = top?.take(3).map((e) => speciesLabel(e.speciesCode)).toList() ?? const [];
    return Card(
      child: ListTile(
        leading: const Icon(Icons.set_meal_outlined),
        title: Text('${DateTime.now().month}월 전후 내 어종'),
        subtitle: Text(names.isEmpty
            ? '이 시기에 남긴 조과가 아직 없어요'
            : names.join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.species),
      ),
    );
  }
}

/// 앱이 도중에 꺼져 끝맺지 못한 경로 기록이 있으면 저장하거나 버리게 한다.
class _InterruptedBanner extends ConsumerWidget {
  const _InterruptedBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(interruptedTracksProvider).value;
    if (tracks == null || tracks.isEmpty) return const SizedBox.shrink();
    final t = tracks.first;
    final repo = ref.read(trackRepositoryProvider);

    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('끝나지 않은 경로 기록이 있어요',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${formatDateTime(t.startedAt)}에 시작한 기록이에요. '
                '남아 있는 위치 ${t.sampleCount}개로 마무리할까요?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    await repo.discard(t.id);
                    ref.invalidate(interruptedTracksProvider);
                  },
                  child: const Text('버리기'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final outcome = await recoverTrack(repo, t);
                    ref.invalidate(interruptedTracksProvider);
                    if (outcome == RecoveryOutcome.saved && context.mounted) {
                      context.push(Routes.candidatesOf(t.id));
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
