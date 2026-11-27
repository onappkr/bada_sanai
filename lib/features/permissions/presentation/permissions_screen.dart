import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../application/permission_providers.dart';
import '../domain/permission_service.dart';

/// S02 권한 안내: 이유와 함께 권한을 요청한다. 거부해도 앱은 쓸 수 있다.
/// 설정 앱에 다녀오면 상태를 다시 읽는다.
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      for (final p in AppPermission.values) {
        ref.invalidate(permissionStateProvider(p));
      }
    }
  }

  Future<void> _onTap(AppPermission p, PermissionState current) async {
    final service = ref.read(permissionServiceProvider);
    try {
      if (current == PermissionState.blocked) {
        await service.openSettings();
      } else {
        await service.request(p);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('권한을 요청하지 못했습니다: $e')));
      }
    }
    ref.invalidate(permissionStateProvider(p));
  }

  void _done() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromSettings = context.canPop();
    return Scaffold(
      appBar: AppBar(title: const Text('권한 안내')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('이 기능들을 쓰려면 아래 권한이 필요해요. 지금 허용하지 않아도 앱은 쓸 수 있고, '
              '설정에서 언제든 바꿀 수 있어요.'),
          const SizedBox(height: 12),
          for (final p in AppPermission.values) _tile(p),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _done,
            child: Text(fromSettings ? '닫기' : '다음에 할게요'),
          ),
        ],
      ),
    );
  }

  Widget _tile(AppPermission p) {
    final state = ref.watch(permissionStateProvider(p));
    final value = state.value;
    final label = switch (value) {
      PermissionState.granted => '허용됨',
      PermissionState.blocked => '설정에서 허용',
      PermissionState.denied => '허용하기',
      null => '확인 중',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(p.reason),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: value == PermissionState.granted
                  ? const Chip(avatar: Icon(Icons.check_circle, size: 18), label: Text('허용됨'))
                  : OutlinedButton(
                      onPressed: value == null ? null : () => _onTap(p, value),
                      child: Text(label),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
