import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/tracking_providers.dart';

/// S10 도착 알림 수락: "바다에 도착하셨네요" 알림을 눌렀을 때 들어오는 화면.
/// 수락하면 경로 기록을 시작하고 S11로, "나중에"는 기록하지 않고 닫는다.
class ArrivalScreen extends ConsumerWidget {
  const ArrivalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('도착 알림')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sailing, size: 96, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('바다에 도착하셨네요', style: text.headlineSmall),
            const SizedBox(height: 8),
            const Text('이동 경로를 저장할까요?\n오래 머문 자리는 포인트 후보로 만들어 드려요.',
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await ref.read(trackingProvider.notifier).start();
                  if (context.mounted) context.pushReplacement(Routes.tracking);
                },
                child: const Text('기록 시작'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
                child: const Text('나중에'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
