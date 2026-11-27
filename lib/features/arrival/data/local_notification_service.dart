import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/arrival_watcher.dart';
import '../domain/notification_service.dart';

/// flutter_local_notifications 기반 구현. Android와 iOS에서만 동작하고,
/// 그 밖의 환경(웹 등)에서는 아무것도 하지 않는다.
class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _taps = StreamController<String>.broadcast();
  bool _inited = false;

  static const _channelId = 'arrival';
  static const _arrivalNotificationId = 1001;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> init() async {
    if (_inited || !_supported) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // 권한은 사용자가 도착 알림을 켤 때 따로 요청한다(처음 실행 때 묻지 않는다).
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _taps.add(payload);
      },
    );
    _inited = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<void> showArrival() async {
    if (!_supported) return;
    await init();
    final text = arrivalNotificationText();
    await _plugin.show(
      id: _arrivalNotificationId,
      title: text.title,
      body: text.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          '도착 알림',
          channelDescription: '바다에 도착하면 이동 경로 기록을 제안하는 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: arrivalNotificationPayload,
    );
  }

  @override
  Future<String?> launchPayload() async {
    if (!_supported) return null;
    await init();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }
}

/// 알림을 지원하지 않는 환경(웹 미리보기·테스트)용. 띄운 알림 횟수를 세어 둔다.
class FakeNotificationService implements NotificationService {
  final _taps = StreamController<String>.broadcast();
  int arrivalShown = 0;
  bool permissionGranted = true;
  String? launch;

  @override
  Stream<String> get taps => _taps.stream;

  /// 시험·미리보기에서 사용자가 알림을 누른 것처럼 흘려보낸다.
  void tap(String payload) => _taps.add(payload);

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> showArrival() async {
    arrivalShown++;
    // 미리보기에서는 화면에 알림이 안 뜨므로 콘솔로 확인할 수 있게 남긴다.
    debugPrint('[가짜 알림] 도착 알림 표시 #$arrivalShown');
  }

  @override
  Future<String?> launchPayload() async => launch;
}
