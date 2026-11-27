import '../../../core/geo/geo_point.dart';
import '../../tracking/domain/track_logic.dart';
import 'coast_cells.dart';

/// 도착 감지 기준값. 해안 현장 테스트(F2) 후 조정한다.
abstract final class ArrivalConfig {
  /// 해안 셀 안에 이 시간 이상 머물면 도착으로 본다.
  static const dwell = Duration(minutes: 3);

  /// 같은 구역에서는 이 시간 안에 다시 알리지 않는다.
  static const cooldown = Duration(hours: 6);

  /// 셀 반경의 이 배수 밖으로 나가야 "떠났다"고 본다(경계에서 GPS가 흔들려도 머문 시간이 끊기지 않게).
  static const exitFactor = 1.5;

  /// 셀 안에서 받은 측정값 사이가 이보다 벌어지면 연속해서 머문 것으로 보지 않고 시간을 다시 잰다
  /// (앱이 꺼져 있던 동안의 공백을 "머문 시간"으로 세지 않기 위해서).
  static const maxSampleGap = Duration(minutes: 15);

  /// 구역을 나누는 격자 크기(도). 0.01도는 위도 방향 약 1.1km다.
  static const zoneGridDegrees = 0.01;
}

/// 도착했다는 판단.
class ArrivalEvent {
  const ArrivalEvent({required this.at, required this.cell, required this.zone});

  /// 도착으로 판단한 시각(머문 시간이 기준을 넘긴 첫 측정 시각).
  final DateTime at;

  /// 도착한 셀의 중심.
  final GeoPoint cell;

  /// 재알림 제한을 거는 구역 키.
  final String zone;
}

/// 위치 측정값을 하나씩 받아 "해안에 도착했다"를 판단한다.
///
/// 1. 해안 셀 안에 들어온 시각부터 시간을 잰다.
/// 2. [ArrivalConfig.dwell] 이상 머물면 도착 이벤트를 한 번 낸다(같은 체류에서는 다시 내지 않는다).
/// 3. 같은 구역은 [ArrivalConfig.cooldown] 동안 다시 알리지 않는다.
/// 4. 셀 반경의 [ArrivalConfig.exitFactor]배 밖으로 나가면 체류가 끝난 것으로 본다.
///
/// 상태를 가지는 객체이며 프레임워크에 묶이지 않는다. 오차가 큰 측정값은 무시한다.
class ArrivalDetector {
  ArrivalDetector(
    this.cells, {
    this.dwell = ArrivalConfig.dwell,
    this.cooldown = ArrivalConfig.cooldown,
  });

  final CoastCells cells;
  final Duration dwell;
  final Duration cooldown;

  DateTime? _enteredAt;
  DateTime? _lastInsideAt;
  bool _firedThisStay = false;
  final Map<String, DateTime> _lastFiredByZone = {};

  /// 지금 셀 안에 머무는 중인지(테스트·화면 표시용).
  bool get isInside => _enteredAt != null;

  /// 측정값 [s]를 넣는다. 도착으로 판단하면 [ArrivalEvent], 아니면 null.
  ArrivalEvent? onSample(LocationSample s) {
    final acc = s.accuracyM;
    if (acc != null && acc > TrackConfig.maxAccuracyM) return null; // 믿을 수 없는 값은 건너뛴다

    final here = s.point;
    final inside = cells.cellContaining(here);

    if (inside == null) {
      // 경계 근처에서 흔들리는 것은 떠난 것으로 치지 않는다.
      final stillNear = cells.cellContaining(here, radiusM: cells.cellRadiusM * ArrivalConfig.exitFactor);
      if (stillNear == null) {
        _enteredAt = null;
        _lastInsideAt = null;
        _firedThisStay = false;
      }
      return null;
    }

    final lastInside = _lastInsideAt;
    if (_enteredAt != null && lastInside != null && s.time.difference(lastInside) > ArrivalConfig.maxSampleGap) {
      // 측정이 오래 끊겼다가 이어졌다: 새로 들어온 것으로 본다.
      _enteredAt = null;
      _firedThisStay = false;
    }
    _lastInsideAt = s.time;
    _enteredAt ??= s.time;
    if (_firedThisStay) return null;
    if (s.time.difference(_enteredAt!) < dwell) return null;

    _firedThisStay = true; // 알림이 제한에 걸려도 이 체류에서는 다시 판단하지 않는다
    final zone = zoneOf(inside);
    final last = _lastFiredByZone[zone];
    if (last != null && s.time.difference(last) < cooldown) return null;

    _lastFiredByZone[zone] = s.time;
    return ArrivalEvent(at: s.time, cell: inside, zone: zone);
  }

  /// 셀이 속한 구역 키. 가까운 셀들은 같은 구역이라, 해안을 따라 걸어도 반복해서 알리지 않는다.
  static String zoneOf(GeoPoint cell) {
    const g = ArrivalConfig.zoneGridDegrees;
    return '${(cell.lat / g).floor()},${(cell.lng / g).floor()}';
  }

  /// 체류 상태와 재알림 기록을 모두 지운다(설정에서 감지를 껐다 켤 때 등).
  void reset() {
    _enteredAt = null;
    _lastInsideAt = null;
    _firedThisStay = false;
    _lastFiredByZone.clear();
  }
}
