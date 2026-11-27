import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/handler_permission_service.dart';
import '../domain/permission_service.dart';

final permissionServiceProvider =
    Provider<PermissionService>((ref) => const HandlerPermissionService());

/// 권한별 현재 상태. 요청·설정 변경 뒤에는 `ref.invalidate`로 다시 읽는다.
final permissionStateProvider =
    FutureProvider.autoDispose.family<PermissionState, AppPermission>((ref, p) {
  return ref.watch(permissionServiceProvider).status(p);
});
