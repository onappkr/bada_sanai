import 'split_calculator.dart';

/// 나누어떨어지지 않는 끝전을 누가 부담하는지(팀 설정). 기본은 결제자.
enum RemainderRule { payer, treasurer }

/// 정산 계산 오류. [code]는 서버 함수가 던지는 오류 이름과 같다.
class SettlementError implements Exception {
  const SettlementError(this.code, [this.detail]);

  final String code;
  final String? detail;

  @override
  String toString() => detail == null ? code : '$code: $detail';
}

/// 승인된 비용 하나. 금액은 원 단위 정수.
class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.payerId,
    required this.targets,
  });

  final String id;
  final int amount;
  final String payerId;

  /// 이 비용을 나눠 낼 사람들.
  final List<String> targets;
}

/// 끝전 부담자. 규칙이 가리키는 사람(결제자 또는 총무)이 대상자면 그 사람,
/// 대상자가 아니거나 총무가 없으면 대상자를 id 순으로 정렬한 첫 번째 사람이다.
/// (규칙이 가리키는 사람이 대상자가 아닐 때의 처리는 설계 문서에 정해져 있지 않아 이렇게 가정했다.)
String remainderBearer(
  RemainderRule rule, {
  required String payerId,
  String? treasurerId,
  required List<String> targets,
}) {
  final sorted = [...targets]..sort();
  final preferred = rule == RemainderRule.payer ? payerId : treasurerId;
  return preferred != null && sorted.contains(preferred) ? preferred : sorted.first;
}

/// 비용 하나의 분담액. 대상자를 id 순으로 정렬해 입력 순서와 무관하게 결과가 같다.
/// 합계는 항상 [amount]와 같다.
Map<String, int> computeSplits(int amount, List<String> targets, String bearer) =>
    computeEqualSplit(
      total: amount,
      participants: [...targets]..sort(),
      remainderBearer: bearer,
    );

/// 한 사람의 정산 항목. [net]이 양수면 받을 돈, 음수면 낼 돈.
class SettlementItem {
  const SettlementItem({
    required this.userId,
    required this.shareTotal,
    required this.paidTotal,
  });

  final String userId;

  /// 내가 부담할 몫의 합계.
  final int shareTotal;

  /// 내가 먼저 결제한 금액의 합계.
  final int paidTotal;

  int get net => paidTotal - shareTotal;
}

class SettlementResult {
  const SettlementResult({
    required this.total,
    required this.items,
    required this.transfers,
  });

  final int total;
  final List<SettlementItem> items;
  final List<Transfer> transfers;
}

/// 출조의 승인된 비용으로 정산을 계산한다(서버의 `request_settlement`와 같은 규칙).
///
/// 1. 비용마다 대상자에게 n/n으로 나누고 끝전은 한 사람이 부담한다.
/// 2. 사람별로 부담 합계와 결제 합계를 구해 순액(결제 − 부담)을 낸다.
/// 3. 순액이 큰 채무자와 큰 채권자를 차례로 짝지어 송금 목록을 만든다.
///
/// 오류: 금액이 1 미만이면 `INVALID_AMOUNT`, 대상자가 없으면 `NO_TARGETS`,
/// 결제자·대상자가 출조 참여자가 아니면 `NOT_PARTICIPANT`, 비용이 없으면 `NO_EXPENSES`,
/// 합계 검증에 실패하면 `SETTLEMENT_MISMATCH`.
SettlementResult settle({
  required List<Expense> expenses,
  required List<String> memberIds,
  RemainderRule rule = RemainderRule.payer,
  String? treasurerId,
}) {
  final members = memberIds.toSet();
  if (expenses.isEmpty) throw const SettlementError('NO_EXPENSES');

  final share = {for (final m in members) m: 0};
  final paid = {for (final m in members) m: 0};
  var total = 0;

  for (final e in expenses) {
    if (e.amount < 1) throw SettlementError('INVALID_AMOUNT', e.id);
    if (e.targets.isEmpty) throw SettlementError('NO_TARGETS', e.id);
    if (e.targets.toSet().length != e.targets.length) {
      throw SettlementError('NOT_PARTICIPANT', '${e.id}: 대상자 중복');
    }
    if (!members.contains(e.payerId) || !e.targets.every(members.contains)) {
      throw SettlementError('NOT_PARTICIPANT', e.id);
    }

    final bearer = remainderBearer(rule,
        payerId: e.payerId, treasurerId: treasurerId, targets: e.targets);
    computeSplits(e.amount, e.targets, bearer)
        .forEach((id, amount) => share[id] = share[id]! + amount);
    paid[e.payerId] = paid[e.payerId]! + e.amount;
    total += e.amount;
  }

  final items = [
    for (final id in (members.toList()..sort()))
      SettlementItem(userId: id, shareTotal: share[id]!, paidTotal: paid[id]!),
  ];

  // 서버와 같은 검증: 부담 합계 = 총액, 순액 합계 = 0.
  if (items.fold<int>(0, (a, i) => a + i.shareTotal) != total ||
      items.fold<int>(0, (a, i) => a + i.net) != 0) {
    throw const SettlementError('SETTLEMENT_MISMATCH');
  }

  return SettlementResult(
    total: total,
    items: items,
    transfers: buildTransfers({for (final i in items) i.userId: i.net}),
  );
}
