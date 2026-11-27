import 'dart:convert';

import '../../../core/geo/geo_point.dart';

/// 규칙 데이터가 가리키는 어종 한 가지.
class RuleSpecies {
  const RuleSpecies({required this.code, required this.nameKo});

  final String code;
  final String nameKo;
}

/// "이 해역·이 달·이 장르에서 이 어종을 추천한다"는 규칙 한 줄.
class SpeciesRule {
  const SpeciesRule({
    required this.speciesCode,
    required this.regions,
    required this.months,
    required this.peakMonths,
    required this.genres,
    this.note,
  });

  final String speciesCode;
  final Set<String> regions;
  final Set<int> months;
  final Set<int> peakMonths;

  /// `lure`, `cast`, `jjik`, `boat` 중. 장르를 고르면 이 목록에 그 장르가 있는 규칙만 남는다.
  final Set<String> genres;
  final String? note;
}

class RuleRegion {
  const RuleRegion({
    required this.code,
    required this.nameKo,
    required this.center,
    this.gridNx,
    this.gridNy,
    this.tideStationId,
    this.seaTempStationId,
  });

  final String code;
  final String nameKo;
  final GeoPoint center;

  /// 기상청 격자 좌표(날씨 조회용). 데이터에 없으면 null.
  final int? gridNx;
  final int? gridNy;

  /// 조석 관측소·수온 관측소 ID(예보 원천 조회용). 데이터에 없으면 null.
  final String? tideStationId;
  final String? seaTempStationId;
}

/// 추천 결과 한 줄.
class Recommendation {
  const Recommendation({
    required this.speciesCode,
    required this.nameKo,
    required this.score,
    this.note,
  });

  final String speciesCode;
  final String nameKo;

  /// 2 = 제철(peak_months), 1 = 잡히는 시기(months).
  final int score;
  final String? note;

  bool get isPeak => score == 2;
}

/// 어종 규칙 데이터(`species_rule.json`)와 해역 데이터(`region.json`)를 묶은 것.
/// 데이터 파일만 바꾸면 앱 수정 없이 추천이 달라진다. 실제 값은 전문가 감수가 필요하다.
class RuleBook {
  const RuleBook({
    this.speciesRuleVersion = 0,
    this.regionVersion = 0,
    this.species = const {},
    this.rules = const [],
    this.regions = const [],
  });

  /// 내용이 없는 규칙집. 앱에 기본으로 들어 있는 데이터 파일이 이 상태다.
  static const empty = RuleBook();

  final int speciesRuleVersion;
  final int regionVersion;
  final Map<String, RuleSpecies> species;
  final List<SpeciesRule> rules;
  final List<RuleRegion> regions;

  /// 추천에 쓸 수 있는 데이터가 있는지.
  bool get isUsable => rules.isNotEmpty && regions.isNotEmpty;

  /// 두 JSON 문자열을 읽는다. 형식이 맞지 않으면 [FormatException].
  /// (앱은 실패하면 [empty]를 쓴다.)
  factory RuleBook.parse({required String speciesRuleJson, required String regionJson}) {
    final Object? ruleRoot;
    final Object? regionRoot;
    try {
      ruleRoot = jsonDecode(speciesRuleJson);
      regionRoot = jsonDecode(regionJson);
    } on FormatException {
      throw const FormatException('규칙 데이터가 JSON이 아닙니다');
    }
    try {
      return _parse(ruleRoot, regionRoot);
    } on FormatException {
      rethrow;
    } on Object {
      // 필드 누락·형 불일치(TypeError 등)는 모두 형식 오류로 본다.
      throw const FormatException('규칙 데이터의 형식이 올바르지 않습니다');
    }
  }

  static RuleBook _parse(Object? ruleRoot, Object? regionRoot) {
    final r = ruleRoot as Map<String, dynamic>;
    final g = regionRoot as Map<String, dynamic>;

    final species = <String, RuleSpecies>{};
    for (final e in (r['species'] as List? ?? const [])) {
      final m = e as Map<String, dynamic>;
      final code = m['code'] as String;
      final name = m['name_ko'] as String;
      if (code.isEmpty || name.trim().isEmpty) {
        throw const FormatException('어종 코드나 이름이 비어 있습니다');
      }
      if (species.containsKey(code)) throw FormatException('어종 코드가 중복되었습니다: $code');
      species[code] = RuleSpecies(code: code, nameKo: name.trim());
    }

    Set<int> months(Object? raw, String field) {
      final out = <int>{};
      for (final v in (raw as List? ?? const [])) {
        final n = v as int;
        if (n < 1 || n > 12) throw FormatException('$field에 1~12가 아닌 달이 있습니다: $n');
        out.add(n);
      }
      return out;
    }

    final rules = <SpeciesRule>[];
    for (final e in (r['rules'] as List? ?? const [])) {
      final m = e as Map<String, dynamic>;
      final code = m['species'] as String;
      if (!species.containsKey(code)) {
        throw FormatException('규칙이 정의되지 않은 어종을 가리킵니다: $code');
      }
      final all = months(m['months'], 'months');
      final peak = months(m['peak_months'], 'peak_months');
      rules.add(SpeciesRule(
        speciesCode: code,
        regions: {for (final x in (m['regions'] as List? ?? const [])) x as String},
        // 제철은 반드시 잡히는 시기에도 속한다고 보고 합친다.
        months: {...all, ...peak},
        peakMonths: peak,
        genres: {for (final x in (m['genres'] as List? ?? const [])) x as String},
        note: (m['note'] as String?)?.trim().isEmpty ?? true ? null : (m['note'] as String).trim(),
      ));
    }

    final regions = <RuleRegion>[];
    final seen = <String>{};
    for (final e in (g['regions'] as List? ?? const [])) {
      final m = e as Map<String, dynamic>;
      final code = m['code'] as String;
      if (!seen.add(code)) throw FormatException('해역 코드가 중복되었습니다: $code');
      final c = m['center'] as Map<String, dynamic>;
      final lat = (c['lat'] as num).toDouble();
      final lng = (c['lng'] as num).toDouble();
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
        throw FormatException('해역 $code의 좌표가 올바르지 않습니다');
      }
      final grid = m['grid'] as Map<String, dynamic>?;
      String? stationId(String key) {
        final v = (m[key] as String?)?.trim();
        return (v == null || v.isEmpty) ? null : v;
      }

      regions.add(RuleRegion(
        code: code,
        nameKo: (m['name_ko'] as String).trim(),
        center: GeoPoint(lat, lng),
        gridNx: (grid?['nx'] as num?)?.toInt(),
        gridNy: (grid?['ny'] as num?)?.toInt(),
        tideStationId: stationId('tide_station_id'),
        seaTempStationId: stationId('sea_temp_station_id'),
      ));
    }

    return RuleBook(
      speciesRuleVersion: (r['version'] as num?)?.toInt() ?? 0,
      regionVersion: (g['version'] as num?)?.toInt() ?? 0,
      species: species,
      rules: rules,
      regions: regions,
    );
  }

  /// [position]에서 가장 가까운 해역. [maxDistanceM]보다 멀면 null(데이터가 없는 바다).
  RuleRegion? nearestRegion(GeoPoint position, {double maxDistanceM = 150000}) {
    RuleRegion? best;
    var bestDistance = double.infinity;
    for (final region in regions) {
      final d = position.distanceTo(region.center);
      if (d < bestDistance) {
        bestDistance = d;
        best = region;
      }
    }
    return bestDistance <= maxDistanceM ? best : null;
  }

  /// [regionCode] 해역의 [month]월 추천 어종.
  ///
  /// 점수는 제철(`peak_months`)이면 2점, 잡히는 시기(`months`)만이면 1점이고 그 밖의 달은 추천하지 않는다.
  /// [genre]를 주면 그 장르가 들어 있는 규칙만 남긴다. 같은 어종에 맞는 규칙이 여럿이면 가장
  /// 높은 점수를 쓴다. 점수가 같으면 한글 이름순이다.
  List<Recommendation> recommend({
    required String regionCode,
    required int month,
    String? genre,
  }) {
    final best = <String, Recommendation>{};
    for (final rule in rules) {
      if (!rule.regions.contains(regionCode)) continue;
      if (genre != null && !rule.genres.contains(genre)) continue;
      final score = rule.peakMonths.contains(month) ? 2 : (rule.months.contains(month) ? 1 : 0);
      if (score == 0) continue;
      final current = best[rule.speciesCode];
      if (current != null && current.score >= score) continue;
      best[rule.speciesCode] = Recommendation(
        speciesCode: rule.speciesCode,
        nameKo: species[rule.speciesCode]!.nameKo,
        score: score,
        note: rule.note,
      );
    }
    final list = best.values.toList()
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : a.nameKo.compareTo(b.nameKo);
      });
    return list;
  }
}
