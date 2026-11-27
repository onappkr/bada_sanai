import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../photo/application/photo_providers.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../arrival/application/arrival_providers.dart';
import '../../arrival/domain/arrival_watcher.dart';
import '../application/settings_providers.dart';
import '../domain/data_eraser.dart';

/// S17 설정.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _ArrivalToggle(),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('권한'),
            subtitle: const Text('위치·알림·카메라 권한 확인과 변경'),
            onTap: () => context.push(Routes.permissions),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('백업·복원'),
            subtitle: const Text('기록을 파일로 보관하고 되살려요'),
            onTap: () => context.push(Routes.backup),
          ),
          ListTile(
            leading: const Icon(Icons.slideshow_outlined),
            title: const Text('앱 소개 다시 보기'),
            onTap: () => context.push(Routes.onboarding),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: error),
            title: Text('내 데이터 모두 삭제', style: TextStyle(color: error)),
            subtitle: const Text('일지·포인트·경로·사진을 이 기기에서 지워요'),
            onTap: () => _eraseFlow(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _eraseFlow(BuildContext context, WidgetRef ref) async {
    // 기록 중에 지우면 진행 중인 경로가 어정쩡하게 남으므로 먼저 끝내게 한다.
    if (ref.read(trackingProvider).active) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('경로 기록을 먼저 끝내 주세요.')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _EraseDialog(),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final result = await eraseAllUserData(
        eraser: ref.read(dataEraserProvider),
        deletePhotoFiles: ref.read(photoStoreProvider).deleteAll,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.complete
            ? '모든 기록을 지웠어요.'
            : '기록은 지웠지만 사진 파일 일부를 지우지 못했어요.'),
      ));
      context.go(Routes.home);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지우지 못했어요. 아무것도 지워지지 않았어요. ($e)')));
    }
  }
}

/// 되돌릴 수 없는 작업이라 "삭제"를 직접 입력해야 버튼이 켜진다.
class _EraseDialog extends StatefulWidget {
  const _EraseDialog();

  @override
  State<_EraseDialog> createState() => _EraseDialogState();
}

class _EraseDialogState extends State<_EraseDialog> {
  final _controller = TextEditingController();
  bool _ok = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return AlertDialog(
      title: const Text('내 데이터를 모두 지울까요?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이 기기의 일지, 포인트, 이동 경로, 사진이 모두 지워지고 되돌릴 수 없어요. '
              '백업 파일이 있다면 그 파일은 그대로예요.'),
          const SizedBox(height: 8),
          const Text('지우기 전에 설정의 백업·복원에서 백업해 두는 것을 권해요.'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '계속하려면 "삭제"를 입력하세요',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _ok = v.trim() == '삭제'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: error),
          onPressed: _ok ? () => Navigator.pop(context, true) : null,
          child: const Text('모두 삭제'),
        ),
      ],
    );
  }
}

/// 도착 알림 켜기·끄기. 해안 셀 데이터가 없으면 켤 수 없고 이유를 알려 준다.
class _ArrivalToggle extends ConsumerWidget {
  const _ArrivalToggle();

  static String _subtitle(bool hasData, ArrivalUiState s) {
    if (!hasData) return '해안 데이터가 아직 없어 사용할 수 없어요';
    if (s.enabled) {
      return switch (s.watch.phase) {
        ArrivalWatchPhase.watching => '켜짐 · 해안에서 3분 머물면 알려 드려요',
        ArrivalWatchPhase.error => s.watch.message ?? '위치를 받지 못하고 있어요',
        ArrivalWatchPhase.noData => '해안 데이터가 없어 감지하지 못해요',
        ArrivalWatchPhase.stopped => '준비 중…',
      };
    }
    return '바다에 도착하면 이동 경로 기록을 제안해요';
  }

  static String _failure(EnableResult r) => switch (r) {
        EnableResult.noData => '해안 데이터가 없어 켤 수 없어요.',
        EnableResult.locationDenied => '위치 권한이 필요해요. 권한 화면에서 "항상 허용"으로 바꿔 주세요.',
        EnableResult.notificationDenied => '알림 권한이 필요해요. 설정에서 알림을 허용해 주세요.',
        EnableResult.ok => '',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(arrivalControllerProvider);
    final hasData = ref.watch(coastCellsProvider).value?.isUsable ?? false;
    final controller = ref.read(arrivalControllerProvider.notifier);

    return SwitchListTile(
      secondary: const Icon(Icons.notifications_active_outlined),
      title: const Text('도착 알림'),
      subtitle: Text(_subtitle(hasData, ui)),
      value: ui.enabled,
      // 데이터가 없으면 켤 수 없지만, 이미 켜져 있다면 끌 수는 있어야 한다.
      onChanged: (!hasData && !ui.enabled)
          ? null
          : (on) async {
              if (!on) {
                await controller.disable();
                return;
              }
              final result = await controller.enable();
              if (result != EnableResult.ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_failure(result))));
              }
            },
    );
  }
}
