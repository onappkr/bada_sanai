import 'dart:async';

import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/features/arrival/application/arrival_providers.dart';
import 'package:bada_sanai/features/arrival/data/local_notification_service.dart';
import 'package:bada_sanai/features/arrival/domain/arrival_watcher.dart';
import 'package:bada_sanai/features/arrival/domain/coast_cells.dart';
import 'package:bada_sanai/features/permissions/application/permission_providers.dart';
import 'package:bada_sanai/features/permissions/domain/permission_service.dart';
import 'package:bada_sanai/features/point/data/in_memory_point_repository.dart';
import 'package:bada_sanai/features/settings/application/settings_providers.dart';
import 'package:bada_sanai/features/settings/data/settings_repositories.dart';
import 'package:bada_sanai/features/settings/domain/settings_repository.dart';
import 'package:bada_sanai/features/tracking/application/tracking_providers.dart';
import 'package:bada_sanai/features/tracking/data/in_memory_tracking.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:bada_sanai/features/tracking/domain/tracking_ports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

GeoPoint north(double meters) => GeoPoint(35.0 + meters / 111195, 129.0);

LocationSample at(Duration after, GeoPoint p) =>
    LocationSample(lat: p.lat, lng: p.lng, time: t0.add(after), accuracyM: 8);

class FakeSource implements LocationSource {
  final controller = StreamController<LocationSample>.broadcast();

  @override
  Stream<LocationSample> watch() => controller.stream;
}

class FakePermissions implements PermissionService {
  PermissionState location = PermissionState.granted;
  PermissionState afterRequest = PermissionState.granted;
  int requests = 0;

  @override
  Future<PermissionState> status(AppPermission permission) async => location;

  @override
  Future<PermissionState> request(AppPermission permission) async {
    requests++;
    return location = afterRequest;
  }

  @override
  Future<void> openSettings() async {}
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeSource source;
  late FakePermissions permissions;
  late FakeNotificationService notifications;
  late InMemorySettingsRepository settings;
  late ProviderContainer container;

  ProviderContainer make({CoastCells? cells}) {
    final c = ProviderContainer(overrides: <Override>[
      settingsRepositoryProvider.overrideWithValue(settings),
      permissionServiceProvider.overrideWithValue(permissions),
      notificationServiceProvider.overrideWithValue(notifications),
      coastCellsProvider.overrideWith((ref) => cells ?? CoastCells(cells: [north(0)])),
      arrivalSourceProvider.overrideWithValue(source),
      locationSourceProvider.overrideWithValue(source),
      trackRepositoryProvider.overrideWithValue(InMemoryTrackRepository(InMemoryPointRepository())),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    source = FakeSource();
    permissions = FakePermissions();
    notifications = FakeNotificationService();
    settings = InMemorySettingsRepository();
    container = make();
  });

  ArrivalController controller() => container.read(arrivalControllerProvider.notifier);
  ArrivalUiState ui() => container.read(arrivalControllerProvider);

  test('해안 데이터가 없으면 켤 수 없다', () async {
    container = make(cells: CoastCells.empty);
    expect(await controller().enable(), EnableResult.noData);
    expect(ui().enabled, isFalse);
    expect(await settings.isArrivalWatchEnabled(), isFalse);
  });

  test('권한이 모두 있으면 켜지고 설정에 저장된다', () async {
    expect(await controller().enable(), EnableResult.ok);
    expect(ui().enabled, isTrue);
    expect(ui().watch.phase, ArrivalWatchPhase.watching);
    expect(await settings.isArrivalWatchEnabled(), isTrue);
    expect(permissions.requests, 0); // 이미 허용돼 있으면 다시 묻지 않는다
  });

  test('위치 권한이 없으면 묻고, 거부하면 켜지지 않는다', () async {
    permissions
      ..location = PermissionState.denied
      ..afterRequest = PermissionState.denied;
    expect(await controller().enable(), EnableResult.locationDenied);
    expect(permissions.requests, 1);
    expect(ui().enabled, isFalse);
    expect(await settings.isArrivalWatchEnabled(), isFalse);
  });

  test('위치 권한을 처음 묻는 자리에서 허용하면 켜진다', () async {
    permissions
      ..location = PermissionState.denied
      ..afterRequest = PermissionState.granted;
    expect(await controller().enable(), EnableResult.ok);
  });

  test('알림 권한을 거부하면 켜지지 않는다', () async {
    notifications.permissionGranted = false;
    expect(await controller().enable(), EnableResult.notificationDenied);
    expect(ui().enabled, isFalse);
    expect(await settings.isArrivalWatchEnabled(), isFalse);
  });

  test('해안에 3분 머물면 도착 알림이 한 번 뜬다', () async {
    await controller().enable();
    source.controller.add(at(Duration.zero, north(10)));
    source.controller.add(at(const Duration(minutes: 3), north(10)));
    await pump();
    expect(notifications.arrivalShown, 1);
  });

  test('이미 경로를 기록하는 중이면 도착 알림을 띄우지 않는다', () async {
    await controller().enable();
    await container.read(trackingProvider.notifier).start();
    expect(container.read(trackingProvider).active, isTrue);

    source.controller.add(at(Duration.zero, north(10)));
    source.controller.add(at(const Duration(minutes: 3), north(10)));
    await pump();
    expect(notifications.arrivalShown, 0);
  });

  test('끄면 감시가 멈추고 설정에도 꺼짐으로 저장된다', () async {
    await controller().enable();
    await controller().disable();
    expect(ui().enabled, isFalse);
    expect(await settings.isArrivalWatchEnabled(), isFalse);

    source.controller.add(at(Duration.zero, north(10)));
    source.controller.add(at(const Duration(minutes: 5), north(10)));
    await pump();
    expect(notifications.arrivalShown, 0);
  });

  test('앱을 다시 켤 때 켜 둔 상태였다면 감시를 되살린다', () async {
    await settings.setArrivalWatchEnabled(true);
    await controller().restore();
    expect(ui().enabled, isTrue);
    expect(ui().watch.phase, ArrivalWatchPhase.watching);
  });

  test('꺼 둔 상태였다면 되살리지 않는다', () async {
    await controller().restore();
    expect(ui().enabled, isFalse);
    expect(ui().watch.phase, ArrivalWatchPhase.stopped);
  });

  test('위치를 받지 못하면(오류) 상태에 이유가 남는다', () async {
    await controller().enable();
    source.controller.addError(StateError('위치가 꺼져 있어요'));
    await pump();
    expect(ui().enabled, isTrue); // 사용자가 켜 둔 것은 유지된다
    expect(ui().watch.phase, ArrivalWatchPhase.error);
    expect(ui().watch.message, contains('위치가 꺼져 있어요'));
  });
}
