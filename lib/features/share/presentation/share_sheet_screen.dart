import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../point/application/point_providers.dart';
import '../application/share_providers.dart';
import '../domain/shared_point.dart';

/// S15 공유 시트: 링크를 만들어 복사하거나, 카카오톡·문자 등 시스템 공유창으로 보낸다.
class ShareSheetScreen extends ConsumerStatefulWidget {
  const ShareSheetScreen({super.key, required this.pointId});

  final String pointId;

  @override
  ConsumerState<ShareSheetScreen> createState() => _ShareSheetScreenState();
}

class _ShareSheetScreenState extends ConsumerState<ShareSheetScreen> {
  bool _includeMemo = true;
  bool _includeGenre = true;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(pointProvider(widget.pointId));
    return Scaffold(
      appBar: AppBar(title: const Text('포인트 공유')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했습니다: $e')),
        data: (p) {
          if (p == null) return const Center(child: Text('없는 포인트입니다.'));
          final shared = SharedPoint(
            name: p.name,
            lat: p.lat,
            lng: p.lng,
            genre: _includeGenre ? p.genre : null,
            memo: _includeMemo ? p.memo : null,
          );
          final service = ref.watch(shareLinkServiceProvider);
          final link = service.buildLink(shared);
          final message = service.messageFor(shared, link);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              const Text('이름과 위치가 링크에 담겨요. 사진은 보내지 않아요.'),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('장르 포함'),
                value: _includeGenre && p.genre != null,
                onChanged:
                    p.genre == null ? null : (v) => setState(() => _includeGenre = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('메모 포함'),
                subtitle: const Text('주차·주의사항 같은 개인 메모가 들어있다면 끄세요'),
                value: _includeMemo && p.memo != null,
                onChanged:
                    p.memo == null ? null : (v) => setState(() => _includeMemo = v),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(link.toString(),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: link.toString()));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('링크를 복사했어요.')));
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('링크 복사'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _share(context, message, p.name),
                      icon: const Icon(Icons.share),
                      label: const Text('공유하기'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('공유하기를 누르면 카카오톡·문자 등 설치된 앱을 고를 수 있어요.',
                  style: TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _share(BuildContext context, String message, String name) async {
    try {
      await SharePlus.instance.share(ShareParams(text: message, subject: name));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('공유하지 못했습니다: $e')));
      }
    }
  }
}
