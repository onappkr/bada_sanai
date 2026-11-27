import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/geo/geo_point.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/domain/current_location.dart';
import '../application/species_providers.dart';
import '../domain/rule_book.dart';

/// 현재 위치의 해역에서 이 달에 추천하는 어종(규칙 데이터 기반).
/// 규칙 데이터가 비어 있으면 아무것도 그리지 않는다. 위치는 버튼을 눌렀을 때만 가져온다.
class RulePicksCard extends ConsumerStatefulWidget {
  const RulePicksCard({super.key});

  @override
  ConsumerState<RulePicksCard> createState() => _RulePicksCardState();
}

class _Picks {
  const _Picks({required this.region, required this.items});

  /// 데이터가 있는 해역이 없으면 null(너무 먼 바다).
  final RuleRegion? region;
  final List<Recommendation> items;
}

class _RulePicksCardState extends ConsumerState<RulePicksCard> {
  bool _loading = false;
  String? _error;
  _Picks? _picks;

  Future<void> _find(RuleBook book) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fix = await currentLocation(ref.read(locationSourceProvider));
      final region = book.nearestRegion(GeoPoint(fix.lat, fix.lng));
      final items = region == null
          ? const <Recommendation>[]
          : book.recommend(regionCode: region.code, month: DateTime.now().month);
      if (mounted) setState(() => _picks = _Picks(region: region, items: items));
    } on LocationUnavailable catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(ruleBookProvider).value;
    if (book == null || !book.isUsable) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final picks = _picks;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이 해역·이 시기 추천', style: text.titleMedium),
            const SizedBox(height: 4),
            const Text('지금 위치에서 가까운 해역의 이번 달 추천 어종이에요.'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _find(book),
              icon: const Icon(Icons.my_location),
              label: Text(_loading ? '위치 찾는 중…' : '내 위치로 보기'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (picks != null) ...[
              const SizedBox(height: 12),
              if (picks.region == null)
                const Text('이 위치 근처에는 추천 데이터가 없어요.')
              else ...[
                Text('${picks.region!.nameKo} · ${DateTime.now().month}월', style: text.titleSmall),
                if (picks.items.isEmpty) const Text('이 시기에 추천할 어종이 없어요.'),
                for (final r in picks.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(r.nameKo),
                    subtitle: r.note == null ? null : Text(r.note!),
                    trailing: r.isPeak
                        ? const Chip(label: Text('제철'), visualDensity: VisualDensity.compact)
                        : null,
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
