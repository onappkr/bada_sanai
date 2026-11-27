/// 앱 설정 키-값 저장소(app_setting 테이블).
abstract interface class SettingsRepository {
  Future<String?> get(String key);

  Future<void> set(String key, String value);
}

/// 설정 키 모음.
abstract final class SettingKeys {
  /// 온보딩을 끝까지 봤거나 건너뛰었으면 "1".
  static const onboardingDone = 'onboarding_done';

  /// 도착 알림을 켰으면 "1".
  static const arrivalWatch = 'arrival_watch_enabled';
}

extension SettingsRepositoryX on SettingsRepository {
  Future<bool> isOnboardingDone() async =>
      await get(SettingKeys.onboardingDone) == '1';

  Future<void> markOnboardingDone() => set(SettingKeys.onboardingDone, '1');
}

extension ArrivalSettingX on SettingsRepository {
  Future<bool> isArrivalWatchEnabled() async => await get(SettingKeys.arrivalWatch) == '1';

  Future<void> setArrivalWatchEnabled(bool on) => set(SettingKeys.arrivalWatch, on ? '1' : '0');
}
