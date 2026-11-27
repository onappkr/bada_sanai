import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';

/// S17 설정.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
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
        ],
      ),
    );
  }
}
