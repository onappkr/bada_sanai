import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../application/backup_providers.dart';
import '../domain/backup_service.dart';

/// S18 백업·복원: 파일로 내보내 드라이브·메신저에 보관하고, 파일에서 병합 복원한다.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on FormatException catch (e) {
      _toast('이 파일은 복원할 수 없어요. ${e.message}');
    } catch (e) {
      _toast('실패했습니다: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _export() => _run(() async {
        final snap = await exportBackup(
          ref.read(backupRepositoryProvider),
          ref.read(backupFileGatewayProvider),
          photoFiles: ref.read(backupPhotoFilesProvider),
        );
        _toast('일지 ${snap.liveLogCount}건, 포인트 ${snap.livePointCount}개, 사진 ${snap.photos.length}장을 백업 파일로 만들었어요.');
      });

  Future<void> _restore() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('백업에서 복원할까요?'),
        content: const Text(
          '백업 파일의 일지·포인트를 지금 데이터와 합쳐요.\n'
          '• 없는 항목은 추가해요.\n'
          '• 같은 항목은 더 최근에 고친 쪽을 남겨요.\n'
          '• 지금 데이터를 지우지는 않아요.\n'
          '사진도 함께 들어 있으면 같이 가져와요.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('파일 선택')),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() async {
      final r = await restoreBackup(
        ref.read(backupRepositoryProvider),
        ref.read(backupFileGatewayProvider),
        photoFiles: ref.read(backupPhotoFilesProvider),
      );
      if (r == null) return; // 파일 선택 취소
      _toast('복원했어요. 추가 ${r.added}, 갱신 ${r.updated}, 건너뜀 ${r.skipped}, 사진 ${r.photosAdded}장');
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('백업·복원')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('서버가 없는 앱이라 기록은 이 기기에만 있어요. '
              '기기를 바꾸거나 잃어버려도 되찾을 수 있게 가끔 백업해 두세요.'),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('백업 파일 만들기'),
              subtitle: const Text('일지·포인트·사진을 파일로 만들어 드라이브나 메신저에 보관해요'),
              onTap: _busy ? null : _export,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('백업에서 복원'),
              subtitle: const Text('백업 파일(zip 또는 예전 json)을 골라 지금 데이터와 합쳐요'),
              onTap: _busy ? null : _restore,
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LinearProgressIndicator(),
            ),
          const SizedBox(height: 24),
          Text('알아두세요', style: text.titleSmall),
          const SizedBox(height: 4),
          const Text('• 사진이 많으면 파일이 커질 수 있어요(사진 한 장은 보통 400KB 이하).\n'
              '• 백업 파일에는 위치 정보가 그대로 들어 있으니 믿을 수 있는 곳에만 보관하세요.'),
        ],
      ),
    );
  }
}
