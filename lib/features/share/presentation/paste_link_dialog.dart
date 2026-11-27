import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../domain/share_link_service.dart';

/// 받은 링크(또는 링크가 든 문자)를 붙여 넣어 S16으로 간다.
/// 앱 링크 자동 열기(딥링크)가 붙기 전에도 포인트를 받을 수 있는 경로다.
Future<void> showPasteLinkDialog(BuildContext context) async {
  final controller = TextEditingController();
  String? error;
  final fragment = await showDialog<String>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: const Text('링크로 포인트 받기'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '받은 링크나 메시지를 붙여 넣으세요',
            errorText: error,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => c.pop(), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              try {
                c.pop(ShareLinkService.extractFragment(controller.text));
              } on FormatException {
                setState(() => error = '공유 링크를 찾을 수 없어요.');
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    ),
  );
  controller.dispose();
  if (fragment != null && context.mounted) {
    context.push(Routes.sharedPointOf(fragment));
  }
}
