import 'routes.dart';

/// 처음 실행(온보딩 미완료)이면 온보딩·권한 안내 화면만 열고, 나머지는 온보딩으로 보낸다.
/// 이동이 필요 없으면 null. 순수 함수라 라우터 없이 테스트할 수 있다.
String? onboardingRedirect({required bool done, required String location}) {
  if (done) return null;
  final path = Uri.parse(location).path;
  if (path == Routes.onboarding || path == Routes.permissions) return null;
  return Routes.onboarding;
}
