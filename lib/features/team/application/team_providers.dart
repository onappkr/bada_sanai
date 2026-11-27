import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_team_repository.dart';
import '../domain/team_models.dart';
import '../domain/team_repository.dart';

final teamRepositoryProvider = Provider<TeamRepository>(
  (ref) => DriftTeamRepository(ref.watch(databaseProvider)),
);

final teamsProvider = StreamProvider.autoDispose<List<TeamView>>(
  (ref) => ref.watch(teamRepositoryProvider).watchTeams(),
);

final teamProvider = StreamProvider.autoDispose.family<TeamView?, String>(
  (ref, id) => ref.watch(teamRepositoryProvider).watchTeam(id),
);

final tripsProvider = StreamProvider.autoDispose.family<List<TripView>, String>(
  (ref, teamId) => ref.watch(teamRepositoryProvider).watchTrips(teamId),
);

final tripProvider = StreamProvider.autoDispose.family<TripView?, String>(
  (ref, id) => ref.watch(teamRepositoryProvider).watchTrip(id),
);

final expensesProvider = StreamProvider.autoDispose.family<List<ExpenseView>, String>(
  (ref, tripId) => ref.watch(teamRepositoryProvider).watchExpenses(tripId),
);

/// 정산 안내문을 공유창으로 보내는 창구(테스트·미리보기에서 바꿔 끼운다).
typedef TextSharer = Future<void> Function(String text, {String? subject});

final textSharerProvider = Provider<TextSharer>(
  (ref) => (text, {subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  },
);
