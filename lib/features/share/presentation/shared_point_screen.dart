import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../point/domain/point_models.dart';
import '../application/share_providers.dart';
import '../domain/share_link_service.dart';
import '../domain/shared_point.dart';

/// S16 공유 받은 포인트: 내용을 미리 보여 주고 "내 포인트에 저장"을 받는다.
/// [fragment]는 링크의 `v=1&d=...` 부분이다.
class SharedPointScreen extends ConsumerStatefulWidget {
  const SharedPointScreen({super.key, required this.fragment});

  final String? fragment;

  @override
  ConsumerState<SharedPointScreen> createState() => _SharedPointScreenState();
}

class _SharedPointScreenState extends ConsumerState<SharedPointScreen> {
  bool _saving = false;

  SharedPoint? _point;
  String? _error;

  @override
  void initState() {
    super.initState();
    final f = widget.fragment;
    if (f == null || f.isEmpty) {
      _error = '열 수 있는 공유 링크가 없습니다.';
      return;
    }
    try {
      _point = ref.read(shareLinkServiceProvider).parse(f);
    } on FormatException catch (e) {
      _error = '링크를 읽을 수 없습니다. (${e.message})';
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final result = await ref
          .read(shareImportRepositoryProvider)
          .import(_point!, ShareLinkService.fingerprint(widget.fragment!));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.alreadyImported ? '이미 저장한 포인트예요.' : '내 포인트에 저장했어요.'),
      ));
      context.pushReplacement(Routes.pointDetailOf(result.pointId));
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _point;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('공유 받은 포인트')),
      body: p == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error ?? '', textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(p.name, style: text.headlineSmall),
                if (p.genre != null) Text(p.genre!.label),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.my_location),
                  title: Text('${p.lat.toStringAsFixed(5)}, ${p.lng.toStringAsFixed(5)}'),
                  subtitle: const Text('위도, 경도'),
                ),
                if (p.memo != null) ...[
                  const SizedBox(height: 8),
                  Text('메모', style: text.titleMedium),
                  Text(p.memo!),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('내 포인트에 저장'),
                ),
              ],
            ),
    );
  }
}
