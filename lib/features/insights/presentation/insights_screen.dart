import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../catch_log/domain/catch_log_models.dart';
import '../../point/application/point_providers.dart';
import '../../species/domain/species_catalog.dart';
import '../application/insights_providers.dart';
import '../domain/insights.dart';

/// 내 기록 분석: 지금 가기 좋은 포인트, 시간대·달·바람별 성적. 내 일지만 쓴다.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(insightLogsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('내 기록 분석')),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (list) => list.isEmpty ? const _Empty() : _Body(logs: list),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('아직 분석할 일지가 없어요.\n일지를 남길수록 시간대·시기·포인트별로 어디서 잘 잡혔는지 보여 드려요.',
              textAlign: TextAlign.center),
        ),
      );
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.logs});

  final List<CatchLogView> logs;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  Genre? _genre;

  @override
  Widget build(BuildContext context) {
    final all = widget.logs;
    final logs = _genre == null ? all : [for (final l in all) if (l.genre == _genre) l];
    final text = Theme.of(context).textTheme;
    final summary = summarize(logs);
    final points = {
      for (final p in ref.watch(pointsProvider).value ?? const []) p.id: p.name,
    };
    final now = DateTime.now();
    final spots = recommendSpots(all, now: now, genre: _genre);
    final months = monthStats(logs)..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(label: const Text('전체'), selected: _genre == null, onSelected: (_) => setState(() => _genre = null)),
            for (final g in Genre.values)
              ChoiceChip(label: Text(g.label), selected: _genre == g, onSelected: (_) => setState(() => _genre = g)),
          ],
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('이 장르의 일지가 아직 없어요.')))
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('요약', style: text.titleMedium),
                  const SizedBox(height: 8),
                  Text('출조 ${summary.trips}번 · 잡은 물고기 ${summary.fish}마리'),
                  Text('출조당 평균 ${summary.perTrip.toStringAsFixed(1)}마리 · 꽝 ${(summary.zeroRate * 100).round()}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Section(
            title: _genre == null ? '지금 가기 좋은 곳' : '지금 가기 좋은 곳(${_genre!.label})',
            note: '${now.month}월 전후, ${timeBandOf(now).label} 기록에 가중해서 계산해요.',
            child: spots.isEmpty
                ? Text('포인트를 연결한 일지가 $minLogsForRecommendation개 이상 쌓이면 추천해 드려요.', style: text.bodyMedium)
                : Column(
                    children: [
                      for (final s in spots)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.place_outlined),
                          title: Text(points[s.pointId] ?? '(삭제된 포인트)'),
                          subtitle: Text('${s.trips}번 가서 ${s.fish}마리 · 비슷한 시기 ${s.similarTrips}번'
                              '${s.topSpecies == null ? '' : ' · 주로 ${speciesLabel(s.topSpecies!)}'}'),
                          trailing: Text('${s.score.toStringAsFixed(1)}마리/회'),
                          onTap: points.containsKey(s.pointId) ? () => context.push(Routes.pointDetailOf(s.pointId)) : null,
                        ),
                    ],
                  ),
          ),
          _Section(title: '시간대별', child: _Bars(rows: [for (final s in timeBandStats(logs)) (s.key.label, s.perTrip, s.trips, s.reliable)])),
          _Section(title: '달별', child: _Bars(rows: [for (final s in months) ('${s.key}월', s.perTrip, s.trips, s.reliable)])),
          _Section(
            title: '바람별',
            note: '일지를 쓸 때 자동으로 붙은 날씨가 있는 기록만 셈해요.',
            child: _Bars(
              rows: [for (final s in windStats(logs)) (s.key.label, s.perTrip, s.trips, s.reliable)],
              emptyText: '날씨가 붙은 일지가 아직 없어요.',
            ),
          ),
          const SizedBox(height: 8),
          Text('내 기록만으로 계산한 결과예요. 출조가 $minReliableTrips번 미만인 항목은 우연일 수 있어 흐리게 표시해요. '
              '다른 사람의 기록을 합친 추천은 서버가 생기면 더해져요.', style: text.bodySmall),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.note});

  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleMedium),
          if (note != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(note!, style: text.bodySmall)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// 출조당 마릿수를 가로 막대로. 표본이 적은 줄은 흐리게. 행: (이름, 출조당 마릿수, 출조 수, 믿을 만한지).
class _Bars extends StatelessWidget {
  const _Bars({required this.rows, this.emptyText = '기록이 아직 없어요.'});

  final List<(String, double, int, bool)> rows;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return Text(emptyText);
    final max = rows.map((e) => e.$2).fold<double>(0, (a, b) => a > b ? a : b);
    final small = Theme.of(context).textTheme.bodySmall;
    return Column(
      children: [
        for (final (label, perTrip, trips, reliable) in rows)
          Opacity(
            opacity: reliable ? 1 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 120, child: Text(label, style: small)),
                  Expanded(child: LinearProgressIndicator(value: max == 0 ? 0 : perTrip / max, minHeight: 10)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 92,
                    child: Text('${perTrip.toStringAsFixed(1)}마리 · $trips회', textAlign: TextAlign.right, style: small),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
