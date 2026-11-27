import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_backup_repository.dart';
import '../data/platform_backup_file_gateway.dart';
import '../domain/backup_ports.dart';

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => DriftBackupRepository(ref.watch(databaseProvider)),
);

final backupFileGatewayProvider =
    Provider<BackupFileGateway>((ref) => const PlatformBackupFileGateway());
