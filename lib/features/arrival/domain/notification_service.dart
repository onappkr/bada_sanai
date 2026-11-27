/// 앱이 띄우는 알림. 실제 구현은 기기의 로컬 알림, 미리보기·테스트는 가짜.
abstract interface class NotificationService {
  /// 알림 채널 등을 준비한다. 여러 번 불러도 한 번만 한다.
  Future<void> init();

  /// 알림 권한을 요청한다. 허용되면 true. 알림을 지원하지 않는 환경이면 false.
  Future<bool> requestPermission();

  /// "바다에 도착하셨네요" 알림을 띄운다.
  Future<void> showArrival();

  /// 앱이 실행 중일 때 사용자가 알림을 누르면 그 알림의 payload가 흘러온다.
  Stream<String> get taps;

  /// 앱이 꺼져 있다가 알림을 눌러서 열렸다면 그 알림의 payload, 아니면 null.
  Future<String?> launchPayload();
}
