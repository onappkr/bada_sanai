import 'settlement.dart';
import 'team_models.dart';

/// 팀·출조·비용 저장소. 삭제는 표시만 한다(2차 동기화 대비).
abstract interface class TeamRepository {
  Stream<List<TeamView>> watchTeams();

  Stream<TeamView?> watchTeam(String id);

  Future<String> createTeam(String name);

  Future<void> renameTeam(String id, String name);

  /// 끝전 부담 규칙. [rule]이 총무이면 [treasurerId]가 팀의 활성 멤버여야 한다.
  Future<void> setRule(String teamId, RemainderRule rule, {String? treasurerId});

  Future<String> addMember(String teamId, String name);

  /// 멤버를 팀에서 뺀다. 총무였다면 총무 지정은 풀린다.
  Future<void> removeMember(String memberId);

  /// 팀과 그 출조·비용을 삭제 표시한다.
  Future<void> deleteTeam(String id);

  Stream<List<TripView>> watchTrips(String teamId);

  Stream<TripView?> watchTrip(String id);

  Future<String> createTrip(String teamId, TripInput input);

  /// 정산이 마감된 출조는 [StateError].
  Future<void> updateTrip(String id, TripInput input);

  Future<void> deleteTrip(String id);

  /// 정산을 마감하거나(true) 다시 연다(false).
  Future<void> setSettled(String tripId, bool settled);

  Stream<List<ExpenseView>> watchExpenses(String tripId);

  /// 마감된 출조는 [StateError], 입력이 올바르지 않으면 [ArgumentError].
  Future<String> addExpense(String tripId, ExpenseInput input);

  Future<void> updateExpense(String id, ExpenseInput input);

  Future<void> deleteExpense(String id);
}
