import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_share_import_repository.dart';
import '../domain/share_import_repository.dart';
import '../domain/share_link_service.dart';

final shareLinkServiceProvider =
    Provider<ShareLinkService>((ref) => const ShareLinkService(shareBaseUrl));

final shareImportRepositoryProvider = Provider<ShareImportRepository>(
  (ref) => DriftShareImportRepository(ref.watch(databaseProvider)),
);
