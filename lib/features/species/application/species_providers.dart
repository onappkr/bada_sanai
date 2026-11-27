import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart';
import '../domain/species_stats.dart';

/// 이 시기(지금 달 앞뒤 1달)에 내가 잡은 어종 순위. 일지가 바뀌면 다시 계산한다.
final speciesRankingProvider = StreamProvider.autoDispose<List<SpeciesStat>>((ref) {
  return ref
      .watch(catchLogRepositoryProvider)
      .watchAll()
      .map((logs) => speciesRanking(logs, now: DateTime.now()));
});
