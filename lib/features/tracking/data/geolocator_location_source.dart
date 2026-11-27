import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:geolocator/geolocator.dart';

import '../domain/track_logic.dart';
import '../domain/tracking_ports.dart';

/// geolocator 기반 위치 원천. 지금은 앱이 켜져 있는 동안의 기록을 목표로 하고,
/// Android는 포그라운드 알림을 달아 화면이 꺼져도 이어지게 한다. (실기기 검증 필요)
class GeolocatorLocationSource implements LocationSource {
  const GeolocatorLocationSource();

  @override
  Stream<LocationSample> watch() async* {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('기기의 위치 기능이 꺼져 있어요');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('위치 권한이 필요해요');
    }

    final LocationSettings settings = switch (defaultTargetPlatform) {
      TargetPlatform.android => AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: '경로 기록 중',
            notificationText: '바다 사나이가 이동 경로를 기록하고 있어요',
            enableWakeLock: true,
          ),
        ),
      TargetPlatform.iOS || TargetPlatform.macOS => AppleSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        ),
      _ => const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5),
    };

    await for (final p in Geolocator.getPositionStream(locationSettings: settings)) {
      yield LocationSample(
        lat: p.latitude,
        lng: p.longitude,
        time: p.timestamp,
        accuracyM: p.accuracy,
        // 속도를 모르는 기기는 음수를 주므로 "모름"으로 바꾼다.
        speedMps: p.speed >= 0 ? p.speed : null,
      );
    }
  }
}
