import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/tracking_providers.dart';
import '../domain/track_recorder.dart';

/// S11 경로 기록 중: 경과 시간, 이동 거리, 현재 위치, 일시정지·종료.
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(trackingProvider);
    final controller = ref.read(trackingProvider.notifier);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('경로 기록')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (s.phase) {
          RecorderPhase.idle => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('기록 중인 경로가 없어요.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('기록 시작'),
                  ),
                ],
              ),
            ),
          RecorderPhase.saving => const Center(child: CircularProgressIndicator()),
          _ => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Chip(
                    avatar: Icon(
                      s.phase == RecorderPhase.paused ? Icons.pause_circle : Icons.fiber_manual_record,
                      color: s.phase == RecorderPhase.paused ? null : Colors.red,
                      size: 18,
                    ),
                    label: Text(s.phase == RecorderPhase.paused ? '일시정지' : '기록 중'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(_formatElapsed(s.elapsed),
                    style: text.displayMedium, textAlign: TextAlign.center),
                Text('경과 시간', textAlign: TextAlign.center, style: text.bodySmall),
                const SizedBox(height: 16),
                Text(_formatDistance(s.distanceM),
                    style: text.headlineMedium, textAlign: TextAlign.center),
                Text('이동 거리', textAlign: TextAlign.center, style: text.bodySmall),
                const SizedBox(height: 16),
                Text(
                  s.last == null
                      ? '위치를 찾는 중…'
                      : '${s.last!.lat.toStringAsFixed(5)}, ${s.last!.lng.toStringAsFixed(5)}',
                  textAlign: TextAlign.center,
                ),
                if (s.error != null) ...[
                  const SizedBox(height: 12),
                  Text(s.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: s.phase == RecorderPhase.paused
                            ? controller.resume
                            : controller.pause,
                        icon: Icon(s.phase == RecorderPhase.paused
                            ? Icons.play_arrow
                            : Icons.pause),
                        label: Text(s.phase == RecorderPhase.paused ? '재개' : '일시정지'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _stop(context, controller),
                        icon: const Icon(Icons.stop),
                        label: const Text('종료'),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _confirmDiscard(context, controller),
                  child: const Text('기록 버리기'),
                ),
              ],
            ),
        },
      ),
    );
  }

  Future<void> _stop(BuildContext context, TrackingController controller) async {
    try {
      final id = await controller.stop();
      if (id != null && context.mounted) {
        context.pushReplacement(Routes.candidatesOf(id));
      }
    } catch (_) {
      // 저장 실패는 화면의 오류 문구로 알리고, 기록은 이어지므로 다시 종료할 수 있다.
    }
  }

  Future<void> _confirmDiscard(BuildContext context, TrackingController controller) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('기록을 버릴까요?'),
        content: const Text('지금까지의 경로가 사라져요.'),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: const Text('계속 기록')),
          FilledButton(onPressed: () => c.pop(true), child: const Text('버리기')),
        ],
      ),
    );
    if (ok != true) return;
    await controller.discard();
    if (context.mounted) context.canPop() ? context.pop() : context.go(Routes.home);
  }

  static String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  static String _formatDistance(double m) =>
      m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(2)} km';
}
