import 'package:bada_sanai/app/onboarding_redirect.dart';
import 'package:bada_sanai/app/routes.dart';
import 'package:test/test.dart';

void main() {
  group('온보딩 리다이렉트', () {
    test('완료했으면 어디든 그대로', () {
      for (final loc in ['/', '/logs', '/points/p1?x=1', '/onboarding']) {
        expect(onboardingRedirect(done: true, location: loc), isNull, reason: loc);
      }
    });

    test('미완료면 온보딩·권한 안내만 열린다', () {
      expect(onboardingRedirect(done: false, location: Routes.onboarding), isNull);
      expect(onboardingRedirect(done: false, location: Routes.permissions), isNull);
    });

    test('미완료에 다른 화면으로 가면 온보딩으로 보낸다', () {
      for (final loc in ['/', '/logs', '/logs/new', '/map', '/points/p1', '/p?f=v%3D1', '/settings']) {
        expect(onboardingRedirect(done: false, location: loc), Routes.onboarding,
            reason: loc);
      }
    });

    test('쿼리가 붙은 온보딩 경로도 온보딩으로 인식한다', () {
      expect(onboardingRedirect(done: false, location: '/onboarding?from=x'), isNull);
    });
  });
}
