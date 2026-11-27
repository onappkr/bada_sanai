import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_backup_repository.dart';
import '../data/platform_backup_file_gateway.dart';
import '../../photo/application/photo_providers.dart' show photoStoreProvider;
import '../../photo/domain/photo_ports.dart';
import '../domain/backup_ports.dart';

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => DriftBackupRepository(ref.watch(databaseProvider)),
);

final backupFileGatewayProvider =
    Provider<BackupFileGateway>((ref) => const PlatformBackupFileGateway());

/// 앱 사진 폴더를 백업이 읽고 쓰는 창구.
class PhotoStoreBackupFiles implements BackupPhotoFiles {
  const PhotoStoreBackupFiles(this._store);
  final PhotoStore _store;

  @override
  Future<Uint8List?> read(String path) => _store.readBytes(path);

  @override
  Future<void> write(String path, Uint8List bytes) => _store.writeAt(path, bytes);

  @override
  Future<void> delete(String path) => _store.delete(path);
}

final backupPhotoFilesProvider = Provider<BackupPhotoFiles>(
  (ref) => PhotoStoreBackupFiles(ref.watch(photoStoreProvider)),
);
