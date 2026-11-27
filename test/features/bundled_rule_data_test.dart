import 'dart:io';

import 'package:bada_sanai/features/species/domain/rule_book.dart';
import 'package:test/test.dart';

/// 앱에 실제로 포함되는 데이터 파일(assets/data)이 형식에 맞는지 확인한다.
/// 데이터를 채워 넣을 때 형식이 틀리면 여기서 바로 잡힌다.
void main() {
  final book = RuleBook.parse(
    speciesRuleJson: File('assets/data/species_rule.json').readAsStringSync(),
    regionJson: File('assets/data/region.json').readAsStringSync(),
  );

  test('번들 데이터 파일이 형식에 맞게 읽힌다', () {
    expect(book.speciesRuleVersion, isNonNegative);
    expect(book.regionVersion, isNonNegative);
  });

  test('지금은 비어 있어서 추천 화면이 나타나지 않는다(실제 데이터를 채우면 나타난다)', () {
    expect(book.isUsable, isFalse);
    expect(book.rules, isEmpty);
    expect(book.regions, isEmpty);
  });

  test('pubspec에 데이터 파일 두 개가 번들로 등록되어 있다', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/data/species_rule.json'));
    expect(pubspec, contains('assets/data/region.json'));
  });
}
