import 'package:permission_handler/permission_handler.dart' as ph;

import '../domain/permission_service.dart';

/// permission_handler 기반 구현.
class HandlerPermissionService implements PermissionService {
  const HandlerPermissionService();

  @override
  Future<PermissionState> status(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        // "항상 허용"까지 받아야 앱을 닫고도 도착 감지가 된다.
        return _map(await ph.Permission.locationAlways.status);
      case AppPermission.notification:
        return _map(await ph.Permission.notification.status);
      case AppPermission.camera:
        return _map(await ph.Permission.camera.status);
    }
  }

  @override
  Future<PermissionState> request(AppPermission permission) async {
    switch (permission) {
      case AppPermission.location:
        // 운영체제 규칙상 "사용 중에만"을 먼저 받은 뒤 "항상"을 요청해야 한다.
        final whenInUse = await ph.Permission.locationWhenInUse.request();
        if (!whenInUse.isGranted) return _map(whenInUse);
        return _map(await ph.Permission.locationAlways.request());
      case AppPermission.notification:
        return _map(await ph.Permission.notification.request());
      case AppPermission.camera:
        return _map(await ph.Permission.camera.request());
    }
  }

  @override
  Future<void> openSettings() async {
    await ph.openAppSettings();
  }

  static PermissionState _map(ph.PermissionStatus s) {
    if (s.isGranted || s.isLimited) return PermissionState.granted;
    if (s.isPermanentlyDenied || s.isRestricted) return PermissionState.blocked;
    return PermissionState.denied;
  }
}
