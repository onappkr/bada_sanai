import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/point_providers.dart';
import '../domain/point_models.dart';

/// S07 포인트 목록. 지도 SDK가 정해지면 지도 보기가 이 화면에 추가된다.
class PointListScreen extends ConsumerWidget {
  const PointListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pointsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('내 포인트')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.pointNew),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('포인트 추가'),
      ),
      body: points.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('저장된 포인트가 없습니다.'))
            : ListView.separated(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = items[i];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(p.name),
                    subtitle: Text([
                      if (p.genre != null) p.genre!.label,
                      p.source.label,
                    ].join(' · ')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.pointDetailOf(p.id)),
                  );
                },
              ),
      ),
    );
  }
}
