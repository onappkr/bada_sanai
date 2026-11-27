import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart';
import '../data/rule_book_loader.dart';
import '../domain/rule_book.dart';
import '../domain/species_stats.dart';

/// 이 시기(지금 달 앞뒤 1달)에 내가 잡은 어종 순위. 일지가 바뀌면 다시 계산한다.
final speciesRankingProvider = StreamProvider.autoDispose<List<SpeciesStat>>((ref) {
  return ref
      .watch(catchLogRepositoryProvider)
      .watchAll()
      .map((logs) => speciesRanking(logs, now: DateTime.now()));
});

/// 앱에 포함된 어종 규칙·해역 데이터. 읽지 못하면 빈 규칙집(추천 화면이 숨겨진다).
final ruleBookProvider = FutureProvider<RuleBook>((ref) => loadBundledRuleBook());
