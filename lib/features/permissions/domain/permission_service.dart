/// 앱이 쓰는 권한 종류.
enum AppPermission {
  /// 도착 감지와 이동 경로 기록(앱을 닫아도 동작하려면 "항상 허용").
  location,
  notification,
  camera,
}

enum PermissionState {
  granted,
  denied,

  /// 사용자가 "다시 묻지 않음"을 골랐거나 기기 정책으로 막혀, 설정 앱에서만 바꿀 수 있다.
  blocked,
}

extension AppPermissionInfo on AppPermission {
  String get title => switch (this) {
        AppPermission.location => '위치 (항상 허용)',
        AppPermission.notification => '알림',
        AppPermission.camera => '카메라·사진',
      };

  String get reason => switch (this) {
        AppPermission.location => '바다에 도착했을 때 알려 드리고, 이동 경로와 포인트를 기록하려면 필요해요. '
            '앱을 닫아도 동작하려면 "항상 허용"이어야 해요.',
        AppPermission.notification => '바다에 도착했을 때 경로 기록을 시작할지 물어보는 알림에 써요.',
        AppPermission.camera => '조과와 포인트 사진을 찍거나 앨범에서 고를 때 필요해요.',
      };
}

abstract interface class PermissionService {
  Future<PermissionState> status(AppPermission permission);

  /// 시스템 권한 창을 띄우고 결과를 돌려준다.
  Future<PermissionState> request(AppPermission permission);

  /// 설정 앱의 이 앱 화면을 연다.
  Future<void> openSettings();
}
