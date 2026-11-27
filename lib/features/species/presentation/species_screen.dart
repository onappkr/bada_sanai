import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../application/species_providers.dart';
import '../domain/species_catalog.dart';
import '../domain/species_stats.dart';

/// S13 어종: 이 시기에 내가 잡은 어종 순위. 내 기록만 쓰며, 지역별 추천은 자료가 갖춰지면 더한다.
class SpeciesScreen extends ConsumerWidget {
  const SpeciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(speciesRankingProvider);
    final month = DateTime.now().month;
    return Scaffold(
      appBar: AppBar(title: const Text('이 시기 내 어종')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('$month월 전후에 내가 잡은 어종이에요.',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('앞뒤 한 달, 해마다의 기록을 합쳐서 보여 드려요.'),
            const SizedBox(height: 12),
            if (stats.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('이 시기에 남긴 조과가 아직 없어요.\n일지에 조과를 기록하면 여기에 쌓여요.',
                    textAlign: TextAlign.center),
              ),
            for (var i = 0; i < stats.length; i++) _StatTile(rank: i + 1, stat: stats[i]),
            const SizedBox(height: 16),
            const Text('내 기록만으로 계산한 결과라 기록이 적으면 부정확할 수 있어요. '
                '지역·물때를 반영한 추천은 준비 중이에요.',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.rank, required this.stat});

  final int rank;
  final SpeciesStat stat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text('$rank')),
      title: Text(speciesLabel(stat.speciesCode)),
      subtitle: Text([
        '${stat.logCount}번 출조',
        if (stat.maxLengthCm != null) '최대 ${stat.maxLengthCm!.toStringAsFixed(0)}cm',
      ].join(' · ')),
      trailing: Text('${stat.totalCount}마리',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
