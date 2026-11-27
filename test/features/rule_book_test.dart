import 'dart:convert';

import 'package:bada_sanai/core/geo/geo_point.dart';
import 'package:bada_sanai/features/species/domain/rule_book.dart';
import 'package:test/test.dart';

// 아래 값은 모두 형식을 시험하기 위한 가짜 데이터다(실제 낚시 정보가 아니다).
Map<String, dynamic> speciesRuleJson({List<Map<String, dynamic>>? rules, List<Map<String, dynamic>>? species}) => {
      'version': 3,
      'species': species ??
          [
            {'code': 'SP-001', 'name_ko': '나어종', 'image': 'a.webp'},
            {'code': 'SP-002', 'name_ko': '가어종'},
            {'code': 'SP-003', 'name_ko': '다어종'},
          ],
      'rules': rules ??
          [
            {
              'species': 'SP-001',
              'regions': ['R-1', 'R-2'],
              'months': [5, 6, 7, 8, 9, 10],
              'peak_months': [7, 8, 9],
              'genres': ['lure', 'cast'],
              'note': '참고용 설명',
            },
            {
              'species': 'SP-002',
              'regions': ['R-1'],
              'months': [7, 8],
              'peak_months': [],
              'genres': ['lure'],
            },
            {
              'species': 'SP-003',
              'regions': ['R-2'],
              'months': [1, 2, 12],
              'peak_months': [1],
              'genres': ['jjik'],
            },
          ],
    };

Map<String, dynamic> regionJson({List<Map<String, dynamic>>? regions}) => {
      'version': 1,
      'regions': regions ??
          [
            {
              'code': 'R-1',
              'name_ko': '가해역',
              'center': {'lat': 35.0, 'lng': 129.0},
              'grid': {'nx': 1, 'ny': 1},
              'tide_station_id': 'T1',
              'sea_temp_station_id': 'S1',
            },
            {
              'code': 'R-2',
              'name_ko': '나해역',
              'center': {'lat': 37.5, 'lng': 129.2},
            },
          ],
    };

RuleBook build({Map<String, dynamic>? rule, Map<String, dynamic>? region}) => RuleBook.parse(
      speciesRuleJson: jsonEncode(rule ?? speciesRuleJson()),
      regionJson: jsonEncode(region ?? regionJson()),
    );

List<String> names(List<Recommendation> r) => [for (final x in r) x.nameKo];

void main() {
  group('읽기', () {
    test('정상 파일을 읽는다', () {
      final b = build();
      expect(b.speciesRuleVersion, 3);
      expect(b.regionVersion, 1);
      expect(b.species.length, 3);
      expect(b.rules.length, 3);
      expect(b.regions.map((r) => r.code), ['R-1', 'R-2']);
      expect(b.isUsable, isTrue);
    });

    test('해역의 격자·관측소 ID를 읽고, 없으면 null', () {
      final b = build();
      final r1 = b.regions.first;
      expect((r1.gridNx, r1.gridNy), (1, 1));
      expect(r1.tideStationId, 'T1');
      expect(r1.seaTempStationId, 'S1');
      final r2 = b.regions.last; // grid·관측소 없이 center만
      expect((r2.gridNx, r2.gridNy), (null, null));
      expect(r2.tideStationId, isNull);
      expect(r2.seaTempStationId, isNull);
    });

    test('빈 규칙집은 쓸 수 없고 추천은 비어 있다', () {
      expect(RuleBook.empty.isUsable, isFalse);
      expect(RuleBook.empty.recommend(regionCode: 'R-1', month: 7), isEmpty);
      expect(RuleBook.empty.nearestRegion(const GeoPoint(35, 129)), isNull);
    });

    test('규칙 없이 어종·해역만 있어도 읽힌다(쓸 수는 없다)', () {
      final b = build(rule: speciesRuleJson(rules: []));
      expect(b.rules, isEmpty);
      expect(b.isUsable, isFalse);
    });

    test('제철(peak_months)은 잡히는 시기(months)에도 포함된 것으로 본다', () {
      final b = build(
        rule: speciesRuleJson(rules: [
          {'species': 'SP-001', 'regions': ['R-1'], 'months': [5], 'peak_months': [8], 'genres': ['lure']},
        ]),
      );
      expect(b.rules.single.months, {5, 8});
    });

    group('형식 오류는 FormatException', () {
      void bad(String why, Map<String, dynamic> rule, [Map<String, dynamic>? region]) {
        test(why, () => expect(() => build(rule: rule, region: region), throwsFormatException));
      }

      bad('규칙이 정의되지 않은 어종을 가리킴', speciesRuleJson(rules: [
        {'species': 'SP-999', 'regions': ['R-1'], 'months': [1], 'peak_months': [], 'genres': []},
      ]));
      bad('1~12가 아닌 달', speciesRuleJson(rules: [
        {'species': 'SP-001', 'regions': ['R-1'], 'months': [13], 'peak_months': [], 'genres': []},
      ]));
      bad('어종 코드 중복', speciesRuleJson(species: [
        {'code': 'A', 'name_ko': '가'},
        {'code': 'A', 'name_ko': '나'},
      ], rules: []));
      bad('어종 이름이 비어 있음', speciesRuleJson(species: [
        {'code': 'A', 'name_ko': '  '},
      ], rules: []));
      bad('해역 코드 중복', speciesRuleJson(), regionJson(regions: [
        {'code': 'R', 'name_ko': '가', 'center': {'lat': 1.0, 'lng': 1.0}},
        {'code': 'R', 'name_ko': '나', 'center': {'lat': 2.0, 'lng': 2.0}},
      ]));
      bad('해역 좌표 범위 초과', speciesRuleJson(), regionJson(regions: [
        {'code': 'R', 'name_ko': '가', 'center': {'lat': 95.0, 'lng': 1.0}},
      ]));
      bad('해역에 center 없음', speciesRuleJson(), regionJson(regions: [
        {'code': 'R', 'name_ko': '가'},
      ]));
    });

    test('JSON이 아니거나 최상위가 객체가 아니면 FormatException', () {
      expect(() => RuleBook.parse(speciesRuleJson: '안녕', regionJson: '{}'), throwsFormatException);
      expect(() => RuleBook.parse(speciesRuleJson: '[]', regionJson: '{}'), throwsFormatException);
    });
  });

  group('가장 가까운 해역', () {
    final b = build();

    test('가까운 중심의 해역을 고른다', () {
      expect(b.nearestRegion(const GeoPoint(35.05, 129.02))!.code, 'R-1');
      expect(b.nearestRegion(const GeoPoint(37.4, 129.1))!.code, 'R-2');
    });

    test('너무 멀면 null(데이터가 없는 바다)', () {
      // 제주 부근: 두 해역 중심에서 모두 150km보다 멀다.
      expect(b.nearestRegion(const GeoPoint(33.4, 126.5)), isNull);
      expect(b.nearestRegion(const GeoPoint(33.4, 126.5), maxDistanceM: 1e7), isNotNull);
    });
  });

  group('추천', () {
    final b = build();

    test('제철 2점·일반 1점, 그 밖의 달은 제외하고 점수 높은 순', () {
      final r = b.recommend(regionCode: 'R-1', month: 7);
      // SP-001(제철 7월=2점, 나어종) / SP-002(7월 months=1점, 가어종)
      expect(names(r), ['나어종', '가어종']);
      expect([for (final x in r) x.score], [2, 1]);
      expect(r.first.isPeak, isTrue);
      expect(r.first.note, '참고용 설명');
      expect(r.last.note, isNull);
    });

    test('잡히는 시기만인 달은 1점', () {
      final r = b.recommend(regionCode: 'R-1', month: 5);
      expect(names(r), ['나어종']);
      expect(r.single.score, 1);
    });

    test('규칙에 없는 달이나 해역은 추천하지 않는다', () {
      expect(b.recommend(regionCode: 'R-1', month: 12), isEmpty);
      expect(b.recommend(regionCode: 'R-9', month: 7), isEmpty);
    });

    test('장르를 고르면 그 장르가 있는 규칙만 남는다', () {
      expect(names(b.recommend(regionCode: 'R-1', month: 7, genre: 'cast')), ['나어종']);
      expect(names(b.recommend(regionCode: 'R-1', month: 7, genre: 'lure')), ['나어종', '가어종']);
      expect(b.recommend(regionCode: 'R-1', month: 7, genre: 'jjik'), isEmpty);
    });

    test('점수가 같으면 한글 이름순', () {
      final tie = build(
        rule: speciesRuleJson(rules: [
          {'species': 'SP-001', 'regions': ['R-1'], 'months': [7], 'peak_months': [], 'genres': ['lure']},
          {'species': 'SP-002', 'regions': ['R-1'], 'months': [7], 'peak_months': [], 'genres': ['lure']},
          {'species': 'SP-003', 'regions': ['R-1'], 'months': [7], 'peak_months': [], 'genres': ['lure']},
        ]),
      );
      expect(names(tie.recommend(regionCode: 'R-1', month: 7)), ['가어종', '나어종', '다어종']);
    });

    test('같은 어종의 규칙이 여럿이면 가장 높은 점수 하나만 쓴다', () {
      final multi = build(
        rule: speciesRuleJson(rules: [
          {'species': 'SP-001', 'regions': ['R-1'], 'months': [7], 'peak_months': [], 'genres': ['lure'], 'note': '일반'},
          {'species': 'SP-001', 'regions': ['R-1'], 'months': [], 'peak_months': [7], 'genres': ['lure'], 'note': '제철'},
        ]),
      );
      final r = multi.recommend(regionCode: 'R-1', month: 7);
      expect(r.length, 1);
      expect(r.single.score, 2);
      expect(r.single.note, '제철');
    });

    test('12월과 1월처럼 해를 넘기는 제철도 달 번호로 다룬다', () {
      final r = b.recommend(regionCode: 'R-2', month: 1);
      expect(names(r), ['다어종']);
      expect(r.single.score, 2);
      expect(names(b.recommend(regionCode: 'R-2', month: 12)), ['다어종']);
    });
  });
}
