import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/settings_repositories.dart';
import '../domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(databaseProvider)),
);

/// 시작할 때 저장소에서 읽어 둔 온보딩 완료 여부. 라우터가 동기로 판단해야 해서
/// `main()`에서 먼저 읽어 이 provider를 덮어쓴다.
final initialOnboardingDoneProvider = Provider<bool>((ref) => false);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.watch(initialOnboardingDoneProvider);

  /// 온보딩을 끝냈거나 건너뛰었다. 저장에 실패해도 이번 실행에서는 앱을 쓸 수 있게 한다.
  Future<void> complete() async {
    state = true;
    try {
      await ref.read(settingsRepositoryProvider).markOnboardingDone();
    } catch (_) {
      // 다음 실행 때 온보딩이 한 번 더 보일 뿐이다.
    }
  }
}

final onboardingDoneProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
