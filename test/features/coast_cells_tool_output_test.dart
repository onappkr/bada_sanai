import 'dart:io';

import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/features/arrival/domain/arrival_detector.dart';
import 'package:bada_sanai/features/arrival/domain/coast_cells.dart';
import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:test/test.dart';

/// `tool/make_coast_cells.py`가 만든 파일을 앱의 파서가 그대로 읽는지 확인한다(파이썬과 Dart의 교차 검증).
/// fixture는 합성 해안선(tool/testdata/synthetic_coast.geojson)에서 도구로 만든 것이다.
void main() {
  final cells = CoastCells.parse(File('test/fixtures/coast_cells_tool_output.json').readAsStringSync());

  test('도구가 만든 파일을 앱이 읽는다', () {
    expect(cells.version, 7);
    expect(cells.cellRadiusM, 100);
    expect(cells.isUsable, isTrue);
    expect(cells.cells.length, greaterThan(10));
  });

  test('모든 셀 좌표가 범위 안이다', () {
    for (final c in cells.cells) {
      expect(c.lat, inInclusiveRange(-90, 90));
      expect(c.lng, inInclusiveRange(-180, 180));
    }
  });

  test('이웃한 셀 사이 간격이 반경의 두 배(200m) 이하라 해안을 따라 빈틈이 없다', () {
    final sorted = [...cells.cells];
    // 선을 따라 만들어졌으므로 각 셀에서 가장 가까운 다른 셀까지의 거리가 간격(150m) 근처여야 한다.
    for (final c in sorted) {
      final nearest = sorted
          .where((o) => o != c)
          .map(c.distanceTo)
          .reduce((a, b) => a < b ? a : b);
      expect(nearest, lessThanOrEqualTo(200), reason: '$c 주변에 빈틈');
    }
  });

  test('해안 셀 위에 3분 머물면 도착으로 판단한다(도구 출력과 감지 로직의 연결)', () {
    final spot = cells.cells[cells.cells.length ~/ 2];
    final t0 = DateTime.utc(2026, 11, 27, 6);
    final detector = ArrivalDetector(cells);
    LocationSample at(int minutes) =>
        LocationSample(lat: spot.lat, lng: spot.lng, time: t0.add(Duration(minutes: minutes)), accuracyM: 5);
    expect(detector.onSample(at(0)), isNull);
    expect(detector.onSample(at(3)), isNotNull);
  });

  test('가까운 셀 N개 선택이 거리순으로 동작한다', () {
    const probe = GeoPoint(35.0, 129.0);
    final five = cells.nearest(probe, 5);
    expect(five.length, 5);
    for (var i = 1; i < five.length; i++) {
      expect(probe.distanceTo(five[i]), greaterThanOrEqualTo(probe.distanceTo(five[i - 1])));
    }
  });
}
