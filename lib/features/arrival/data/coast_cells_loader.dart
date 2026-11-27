import 'package:flutter/services.dart' show rootBundle;

import '../domain/coast_cells.dart';

const coastCellsAsset = 'assets/data/coast_cells.json';

/// 앱에 포함된 해안 셀 데이터를 읽는다. 없거나 형식이 틀리면 빈 데이터를 돌려주고,
/// 도착 알림만 "사용할 수 없음"이 될 뿐 앱의 다른 기능에는 영향이 없다.
Future<CoastCells> loadBundledCoastCells() async {
  try {
    return CoastCells.parse(await rootBundle.loadString(coastCellsAsset));
  } catch (_) {
    return CoastCells.empty;
  }
}
