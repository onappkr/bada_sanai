import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/backup_ports.dart';

/// 임시 폴더에 백업 파일을 만들어 공유창으로 보내고, 파일 선택창으로 불러온다.
class PlatformBackupFileGateway implements BackupFileGateway {
  const PlatformBackupFileGateway();

  /// 이 크기를 넘는 파일은 백업이 아니라고 보고 읽지 않는다.
  static const _maxBytes = 500 * 1024 * 1024;

  @override
  Future<void> export(String filename, Uint8List bytes, String mimeType) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: mimeType)],
      subject: '바다 사나이 백업',
    ));
  }

  @override
  Future<Uint8List?> pick() async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['zip', 'json'],
    );
    if (f == null) return null;
    final size = await f.length();
    if (size != null && size > _maxBytes) {
      throw const FormatException('파일이 너무 큽니다');
    }
    return f.readAsBytes();
  }
}
