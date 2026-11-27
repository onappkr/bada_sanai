import 'package:flutter/services.dart' show rootBundle;

import '../domain/rule_book.dart';

const speciesRuleAsset = 'assets/data/species_rule.json';
const regionAsset = 'assets/data/region.json';

/// 앱에 포함된 데이터 파일을 읽는다. 파일이 없거나 형식이 틀리면 빈 규칙집을 돌려주고,
/// 추천 화면만 숨겨질 뿐 앱의 다른 기능에는 영향이 없다.
Future<RuleBook> loadBundledRuleBook() async {
  try {
    return RuleBook.parse(
      speciesRuleJson: await rootBundle.loadString(speciesRuleAsset),
      regionJson: await rootBundle.loadString(regionAsset),
    );
  } catch (_) {
    return RuleBook.empty;
  }
}
