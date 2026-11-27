import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_share_import_repository.dart';
import '../domain/deep_link_service.dart';
import '../domain/share_import_repository.dart';
import '../domain/share_link_service.dart';

final shareLinkServiceProvider =
    Provider<ShareLinkService>((ref) => const ShareLinkService(shareBaseUrl));

final shareImportRepositoryProvider = Provider<ShareImportRepository>(
  (ref) => DriftShareImportRepository(ref.watch(databaseProvider)),
);

/// 앱 링크(https://도메인/p#...)를 받는 창구. 미리보기·테스트에서는 받지 않는 구현으로 바꾼다.
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) => AppLinksDeepLinkService());
