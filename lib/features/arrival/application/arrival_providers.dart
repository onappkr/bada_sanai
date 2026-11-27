import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../permissions/application/permission_providers.dart';
import '../../permissions/domain/permission_service.dart';
import '../../settings/application/settings_providers.dart';
import '../../settings/domain/settings_repository.dart';
import '../../tracking/application/tracking_providers.dart';
import '../../tracking/data/geolocator_location_source.dart';
import '../../tracking/domain/tracking_ports.dart';
import '../data/coast_cells_loader.dart';
import '../data/local_notification_service.dart';
import '../domain/arrival_detector.dart';
import '../domain/arrival_watcher.dart';
import '../domain/coast_cells.dart';
import '../domain/notification_service.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => LocalNotificationService());

/// 앱에 포함된 해안 셀. 지금은 비어 있어 도착 알림을 켤 수 없다.
final coastCellsProvider = FutureProvider<CoastCells>((ref) => loadBundledCoastCells());

/// 도착 감시용 위치 원천: 배터리를 아끼려고 30m 이상 움직였을 때만 위치를 받는다.
final arrivalSourceProvider = Provider<LocationSource>(
  (ref) => const GeolocatorLocationSource(
    requestPermission: false,
    distanceFilterM: 30,
    foregroundTitle: '도착 감지 중',
    foregroundText: '해안에 도착하면 알려 드려요',
  ),
);

enum EnableResult { ok, noData, locationDenied, notificationDenied }

class ArrivalUiState {
  const ArrivalUiState({this.enabled = false, this.watch = ArrivalWatchState.stopped});

  /// 사용자가 도착 알림을 켜 두었는지(설정에 저장되어 앱을 다시 켜도 유지된다).
  final bool enabled;
  final ArrivalWatchState watch;
}

class ArrivalController extends Notifier<ArrivalUiState> {
  ArrivalWatcher? _watcher;

  @override
  ArrivalUiState build() {
    ref.onDispose(() => _watcher?.stop());
    return const ArrivalUiState();
  }

  /// 앱을 켤 때 부른다. 켜 둔 상태였다면 감시를 다시 시작한다.
  Future<void> restore() async {
    try {
      if (await ref.read(settingsRepositoryProvider).isArrivalWatchEnabled()) await _start();
    } catch (_) {
      // 설정을 읽지 못하면 꺼진 채로 둔다.
    }
  }

  /// 도착 알림을 켠다. 필요한 권한(위치, 알림)을 묻고, 하나라도 거부되면 켜지 않는다.
  Future<EnableResult> enable() async {
    final cells = await ref.read(coastCellsProvider.future);
    if (!cells.isUsable) return EnableResult.noData;

    final permissions = ref.read(permissionServiceProvider);
    var location = await permissions.status(AppPermission.location);
    if (location != PermissionState.granted) {
      location = await permissions.request(AppPermission.location);
    }
    if (location != PermissionState.granted) return EnableResult.locationDenied;

    if (!await ref.read(notificationServiceProvider).requestPermission()) {
      return EnableResult.notificationDenied;
    }

    await ref.read(settingsRepositoryProvider).setArrivalWatchEnabled(true);
    await _start();
    return EnableResult.ok;
  }

  Future<void> disable() async {
    await _watcher?.stop();
    _watcher = null;
    await ref.read(settingsRepositoryProvider).setArrivalWatchEnabled(false);
    state = const ArrivalUiState();
  }

  Future<void> _start() async {
    final cells = await ref.read(coastCellsProvider.future);
    await _watcher?.stop();
    final watcher = ArrivalWatcher(
      source: ref.read(arrivalSourceProvider),
      cells: cells,
      onArrival: _onArrival,
      onChanged: (s) => state = ArrivalUiState(enabled: true, watch: s),
    );
    _watcher = watcher;
    state = ArrivalUiState(enabled: true, watch: watcher.state);
    await watcher.start();
  }

  void _onArrival(ArrivalEvent event) {
    // 이미 경로를 기록하는 중이면 도착을 또 물을 필요가 없다.
    if (ref.read(trackingProvider).active) return;
    ref.read(notificationServiceProvider).showArrival();
  }
}

final arrivalControllerProvider =
    NotifierProvider<ArrivalController, ArrivalUiState>(ArrivalController.new);
