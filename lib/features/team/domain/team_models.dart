import 'settlement.dart';

/// 팀 멤버. 지금은 기기 안에서 총무가 이름으로 관리하는 사람이다(계정·초대는 서버가 생기면).
class TeamMember {
  const TeamMember({required this.id, required this.name, this.removed = false});

  final String id;
  final String name;

  /// 팀에서 뺀 멤버. 지난 출조의 비용에는 이름이 남아야 해서 행은 지우지 않는다.
  final bool removed;
}

class TeamView {
  const TeamView({
    required this.id,
    required this.name,
    required this.members,
    this.rule = RemainderRule.payer,
    this.treasurerId,
  });

  final String id;
  final String name;

  /// 뺀 멤버를 포함한 전체. 화면에서 고를 때는 [activeMembers]를 쓴다.
  final List<TeamMember> members;
  final RemainderRule rule;
  final String? treasurerId;

  List<TeamMember> get activeMembers => [for (final m in members) if (!m.removed) m];

  String nameOf(String memberId) {
    for (final m in members) {
      if (m.id == memberId) return m.name;
    }
    return '(알 수 없음)';
  }
}

class TripView {
  const TripView({
    required this.id,
    required this.teamId,
    required this.title,
    required this.date,
    required this.participantIds,
    this.settledAt,
  });

  final String id;
  final String teamId;
  final String title;

  /// 출조한 날(로컬 날짜로 본다).
  final DateTime date;
  final List<String> participantIds;

  /// 정산을 마감한 시각. 마감하면 비용을 고칠 수 없다.
  final DateTime? settledAt;

  bool get settled => settledAt != null;
}

class ExpenseView {
  const ExpenseView({
    required this.id,
    required this.tripId,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.targetIds,
  });

  final String id;
  final String tripId;
  final String description;
  final int amount;
  final String payerId;
  final List<String> targetIds;

  Expense toSettlementExpense() =>
      Expense(id: id, amount: amount, payerId: payerId, targets: targetIds);
}

class TripInput {
  const TripInput({required this.title, required this.date, required this.participantIds});

  final String title;
  final DateTime date;
  final List<String> participantIds;
}

class ExpenseInput {
  const ExpenseInput({
    required this.description,
    required this.amount,
    required this.payerId,
    required this.targetIds,
  });

  final String description;
  final int amount;
  final String payerId;
  final List<String> targetIds;
}

/// 입력 검사. 문제가 있으면 사람이 읽을 수 있는 메시지의 [ArgumentError].
/// 두 저장소(Drift·메모리)가 같은 규칙을 쓰도록 여기에 둔다.
void validateTripInput(TripInput input, Set<String> teamMemberIds) {
  if (input.title.trim().isEmpty) throw ArgumentError('출조 이름을 입력해 주세요');
  if (input.participantIds.isEmpty) throw ArgumentError('참여자를 한 명 이상 골라 주세요');
  if (input.participantIds.toSet().length != input.participantIds.length) {
    throw ArgumentError('참여자가 중복되었습니다');
  }
  if (!input.participantIds.every(teamMemberIds.contains)) {
    throw ArgumentError('팀 멤버가 아닌 참여자가 있습니다');
  }
}

void validateExpenseInput(ExpenseInput input, Set<String> participants) {
  if (input.description.trim().isEmpty) throw ArgumentError('내용을 입력해 주세요');
  if (input.amount < 1) throw ArgumentError('금액은 1원 이상이어야 합니다');
  if (input.targetIds.isEmpty) throw ArgumentError('나눠 낼 사람을 한 명 이상 골라 주세요');
  if (input.targetIds.toSet().length != input.targetIds.length) {
    throw ArgumentError('나눌 사람이 중복되었습니다');
  }
  if (!participants.contains(input.payerId)) throw ArgumentError('결제한 사람이 출조 참여자가 아닙니다');
  if (!input.targetIds.every(participants.contains)) {
    throw ArgumentError('출조 참여자가 아닌 사람이 나눌 대상에 있습니다');
  }
}
