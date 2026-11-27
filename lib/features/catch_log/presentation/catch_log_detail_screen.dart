import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../forecast/domain/forecast_models.dart';
import '../../photo/application/photo_providers.dart';
import '../../photo/domain/photo_models.dart';
import '../../photo/presentation/photo_widgets.dart';
import '../../point/application/point_providers.dart';
import '../../species/domain/species_catalog.dart';
import '../application/catch_log_providers.dart';
import '../domain/catch_log_models.dart';
import '../domain/log_environment.dart';
import 'date_format.dart';

/// S06 일지 상세.
class CatchLogDetailScreen extends ConsumerWidget {
  const CatchLogDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(catchLogProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('일지'),
        actions: [
          if (async.value != null) ...[
            IconButton(
              tooltip: '수정',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(Routes.logEditOf(id)),
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
        data: (log) => log == null
            ? const Center(child: Text('삭제되었거나 없는 일지입니다.'))
            : _Body(log: log),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('일지를 삭제할까요?'),
        content: const Text('삭제한 일지는 목록에서 사라집니다.'),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: const Text('취소')),
          FilledButton(onPressed: () => c.pop(true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(catchLogRepositoryProvider).delete(id);
    if (context.mounted) context.pop();
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.log});

  final CatchLogView log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final pointId = log.pointId;
    final point = pointId == null ? null : ref.watch(pointProvider(pointId));
    final photos = ref
            .watch(photosByOwnerProvider((type: OwnerType.log, id: log.id)))
            .value ??
        const [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(log.genre.label, style: text.headlineSmall),
        Text(formatDateTime(log.fishedAt), style: text.bodyMedium),
        if (pointId != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(point?.value?.name ??
                (point?.isLoading ?? true ? '' : '삭제된 포인트')),
            subtitle: const Text('포인트'),
            trailing: point?.value == null ? null : const Icon(Icons.chevron_right),
            onTap: point?.value == null
                ? null
                : () => context.push(Routes.pointDetailOf(pointId)),
          ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 16),
          PhotoStrip(photos: photos),
        ],
        const SizedBox(height: 16),
        Text('조과', style: text.titleMedium),
        if (log.items.isEmpty) const Text('기록된 조과가 없습니다.'),
        for (final it in log.items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(speciesLabel(it.speciesCode)),
            subtitle: Text([
              if (it.lengthCm != null) '${it.lengthCm} cm',
              '${it.count}마리',
              if (it.memo != null) it.memo!,
            ].join(' · ')),
          ),
        const SizedBox(height: 16),
        if (log.genreDetail.isNotEmpty) ...[
          Text('상세', style: text.titleMedium),
          for (final f in log.genre.fields)
            if (log.genreDetail[f.key] != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(f.label),
                subtitle: Text(log.genreDetail[f.key]!),
              ),
          const SizedBox(height: 16),
        ],
        if (log.memo != null) ...[
          Text('메모', style: text.titleMedium),
          Text(log.memo!),
          const SizedBox(height: 16),
        ],
        if (log.environment != null) _EnvironmentCard(env: log.environment!),
      ],
    );
  }
}

/// 일지를 쓸 때 자동으로 붙은 위치와 물때·날씨·수온. 얻지 못한 항목은 보이지 않는다.
class _EnvironmentCard extends StatelessWidget {
  const _EnvironmentCard({required this.env});

  final LogEnvironment env;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final f = env.forecast;
    final lines = <String>[];
    if (env.lat != null && env.lng != null) {
      lines.add('위치 ${env.lat!.toStringAsFixed(5)}, ${env.lng!.toStringAsFixed(5)}');
    }
    if (f != null) {
      final tide = f.tide;
      if (tide?.mulddae != null) lines.add('물때 ${tide!.mulddae}물');
      for (final e in tide?.extremes ?? const <TideExtreme>[]) {
        lines.add('${e.type == TideType.high ? '만조' : '간조'} ${_hhmm(e.time)} · ${e.heightCm}cm');
      }
      final w = f.weather;
      final sky = skyLabel(w?.sky);
      if (sky != null) lines.add('날씨 $sky');
      if (w?.tempC != null) lines.add('기온 ${w!.tempC!.toStringAsFixed(0)}℃');
      if (w?.windMps != null) {
        final dir = w!.windDirDeg == null ? '' : '${windDirectionLabel(w.windDirDeg!)} ';
        lines.add('바람 $dir${w.windMps}m/s');
      }
      if (w?.waveM != null) lines.add('파고 ${w!.waveM}m');
      if (f.seaTempC != null) lines.add('수온 ${f.seaTempC!.toStringAsFixed(1)}℃');
    }
    if (lines.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('기록할 때의 환경', style: text.titleMedium),
            const SizedBox(height: 4),
            Text(f?.stale == true ? '일부는 이전에 받은 정보예요.' : '일지를 쓸 때 자동으로 기록했어요.',
                style: text.bodySmall),
            const SizedBox(height: 8),
            for (final l in lines) Text(l),
          ],
        ),
      ),
    );
  }

  static String _hhmm(DateTime t) {
    final l = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.hour)}:${two(l.minute)}';
  }
}
