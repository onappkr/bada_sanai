/// 정산 분할 계산. 금액은 모두 원 단위 정수.
///
/// [total]을 [participants]에게 n/n 으로 나누고, 나누어떨어지지 않는 나머지(원)는
/// [remainderBearer]가 부담한다(참가자 중 한 명이어야 함).
/// 반환 맵의 합계는 항상 [total]과 같다.
Map<String, int> computeEqualSplit({
  required int total,
  required List<String> participants,
  required String remainderBearer,
}) {
  if (total < 0) throw ArgumentError.value(total, 'total', '0 이상이어야 합니다');
  if (participants.isEmpty) {
    throw ArgumentError.value(participants, 'participants', '비어 있을 수 없습니다');
  }
  if (participants.toSet().length != participants.length) {
    throw ArgumentError.value(participants, 'participants', '중복이 있습니다');
  }
  if (!participants.contains(remainderBearer)) {
    throw ArgumentError.value(
        remainderBearer, 'remainderBearer', '참가자에 포함되어야 합니다');
  }
  final base = total ~/ participants.length;
  final remainder = total - base * participants.length;
  return {
    for (final id in participants)
      id: id == remainderBearer ? base + remainder : base,
  };
}

/// 순 정산액 [balances](양수=받을 돈, 음수=낼 돈, 합계 0)을 최소한의 송금으로 정리한다.
/// 탐욕법: 가장 많이 낼 사람 → 가장 많이 받을 사람 순으로 매칭.
List<Transfer> buildTransfers(Map<String, int> balances) {
  if (balances.values.fold<int>(0, (a, b) => a + b) != 0) {
    throw ArgumentError.value(balances, 'balances', '합계가 0이어야 합니다');
  }
  final debtors = <_Entry>[];
  final creditors = <_Entry>[];
  final sortedKeys = balances.keys.toList()..sort();
  for (final id in sortedKeys) {
    final v = balances[id]!;
    if (v < 0) debtors.add(_Entry(id, -v));
    if (v > 0) creditors.add(_Entry(id, v));
  }
  // 매번 남은 금액이 가장 큰 채무자와 채권자를 다시 골라 짝짓는다(서버의 반복문과 같다).
  // 금액이 같으면 id 순. List.sort는 안정 정렬이 아니므로 id까지 비교해
  // 입력 순서와 무관하게 항상 같은 결과가 나오게 한다.
  _Entry? biggest(List<_Entry> list) {
    _Entry? best;
    for (final e in list) {
      if (e.amount == 0) continue;
      if (best == null ||
          e.amount > best.amount ||
          (e.amount == best.amount && e.id.compareTo(best.id) < 0)) {
        best = e;
      }
    }
    return best;
  }

  final transfers = <Transfer>[];
  while (true) {
    final d = biggest(debtors);
    final c = biggest(creditors);
    if (d == null || c == null) break;
    final amount = d.amount < c.amount ? d.amount : c.amount;
    transfers.add(Transfer(from: d.id, to: c.id, amount: amount));
    d.amount -= amount;
    c.amount -= amount;
  }
  return transfers;
}

class Transfer {
  const Transfer({required this.from, required this.to, required this.amount});

  final String from;
  final String to;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is Transfer &&
      other.from == from &&
      other.to == to &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(from, to, amount);

  @override
  String toString() => 'Transfer($from -> $to, $amount)';
}

class _Entry {
  _Entry(this.id, this.amount);
  final String id;
  int amount;
}
