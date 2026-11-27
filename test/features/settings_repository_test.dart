import 'package:bada_sanai/features/settings/data/settings_repositories.dart';
import 'package:bada_sanai/features/settings/domain/settings_repository.dart';
import 'package:test/test.dart';

void main() {
  test('온보딩 완료 여부: 기본은 미완료, 표시하면 완료', () async {
    final repo = InMemorySettingsRepository();
    expect(await repo.isOnboardingDone(), isFalse);
    await repo.markOnboardingDone();
    expect(await repo.isOnboardingDone(), isTrue);
  });

  test('같은 키를 다시 쓰면 덮어쓴다', () async {
    final repo = InMemorySettingsRepository({'a': '1'});
    await repo.set('a', '2');
    expect(await repo.get('a'), '2');
    expect(await repo.get('none'), isNull);
  });
}
