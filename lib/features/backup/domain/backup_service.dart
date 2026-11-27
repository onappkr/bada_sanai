import 'backup_codec.dart';
import 'backup_models.dart';
import 'backup_ports.dart';

/// "bada_sanai_backup_20261127_1405.json"
String backupFilename(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'bada_sanai_backup_${l.year}${two(l.month)}${two(l.day)}_${two(l.hour)}${two(l.minute)}.json';
}

/// 백업 파일을 만들어 내보낸다. 내보낸 항목 수를 돌려준다.
Future<BackupSnapshot> exportBackup(BackupRepository repo, BackupFileGateway gateway) async {
  final snap = await repo.snapshot();
  await gateway.export(backupFilename(snap.exportedAt), BackupCodec.encode(snap));
  return snap;
}

/// 파일을 고르게 해 병합 복원한다. 취소하면 null, 파일이 이상하면 [FormatException].
Future<RestoreResult?> restoreBackup(BackupRepository repo, BackupFileGateway gateway) async {
  final text = await gateway.pick();
  if (text == null) return null;
  return repo.restore(BackupCodec.decode(text));
}
