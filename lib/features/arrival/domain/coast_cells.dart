import 'dart:convert';

import '../../../core/geo/geo_point.dart';

/// 해안을 작은 셀(점+반경)로 나눈 데이터(`coast_cells.json`).
///
/// 해안선 전체를 지오펜스로 등록할 수 없다(OS가 동시에 등록할 수 있는 수가 제한된다).
/// 그래서 셀을 숫자로 들고 있다가 현재 위치 주변의 가까운 셀 몇 개만 등록한다.
/// 실제 셀 데이터는 공공 해안선 데이터에서 만들어야 하며, 앱에는 비어 있는 파일이 들어 있다.
class CoastCells {
  const CoastCells({
    this.version = 0,
    this.cellRadiusM = defaultCellRadiusM,
    this.cells = const [],
  });

  static const defaultCellRadiusM = 100.0;
  static const empty = CoastCells();

  final int version;

  /// 셀 중심에서 이 거리(미터) 안이면 그 셀에 들어온 것으로 본다.
  final double cellRadiusM;
  final List<GeoPoint> cells;

  bool get isUsable => cells.isNotEmpty;

  /// `{"version": 1, "cell_radius_m": 100, "cells": [[lat, lng], ...]}`를 읽는다.
  /// 형식이 맞지 않으면 [FormatException].
  factory CoastCells.parse(String json) {
    final Object? root;
    try {
      root = jsonDecode(json);
    } on FormatException {
      throw const FormatException('해안 셀 데이터가 JSON이 아닙니다');
    }
    try {
      final m = root as Map<String, dynamic>;
      final radius = (m['cell_radius_m'] as num?)?.toDouble() ?? defaultCellRadiusM;
      if (radius <= 0) throw const FormatException('cell_radius_m은 0보다 커야 합니다');
      final cells = <GeoPoint>[];
      for (final raw in (m['cells'] as List? ?? const [])) {
        final pair = raw as List;
        if (pair.length != 2) throw const FormatException('셀은 [위도, 경도] 두 값이어야 합니다');
        final lat = (pair[0] as num).toDouble();
        final lng = (pair[1] as num).toDouble();
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
          throw FormatException('셀 좌표가 올바르지 않습니다: [$lat, $lng]');
        }
        cells.add(GeoPoint(lat, lng));
      }
      return CoastCells(
        version: (m['version'] as num?)?.toInt() ?? 0,
        cellRadiusM: radius,
        cells: List.unmodifiable(cells),
      );
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('해안 셀 데이터의 형식이 올바르지 않습니다');
    }
  }

  /// [position]에서 가까운 순으로 셀 [count]개(지오펜스로 등록할 셀). 거리가 같으면 입력 순서.
  /// 셀이 [count]보다 적으면 있는 만큼만 돌려준다.
  List<GeoPoint> nearest(GeoPoint position, int count) {
    if (count <= 0) return const [];
    final indexed = [
      for (var i = 0; i < cells.length; i++) (i: i, d: position.distanceTo(cells[i])),
    ]..sort((a, b) {
        final c = a.d.compareTo(b.d);
        return c != 0 ? c : a.i.compareTo(b.i);
      });
    return [for (final e in indexed.take(count)) cells[e.i]];
  }

  /// [position]이 어느 셀 안(반경 [cellRadiusM] 이내)에 있으면 가장 가까운 그 셀, 아니면 null.
  GeoPoint? cellContaining(GeoPoint position, {double? radiusM}) {
    final r = radiusM ?? cellRadiusM;
    GeoPoint? best;
    var bestD = double.infinity;
    for (final c in cells) {
      final d = position.distanceTo(c);
      if (d <= r && d < bestD) {
        bestD = d;
        best = c;
      }
    }
    return best;
  }
}
