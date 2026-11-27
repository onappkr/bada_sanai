import 'settlement.dart';
import 'team_models.dart';

/// 출조의 비용으로 정산 결과를 계산한다. 비용이 없으면 null.
/// 참여자가 아닌 사람이 낀 비용은 저장 단계에서 막히므로 여기서는 [SettlementError]가 나지 않는 것이 정상이다.
SettlementResult? settleTrip({
  required TeamView team,
  required TripView trip,
  required List<ExpenseView> expenses,
}) {
  if (expenses.isEmpty) return null;
  return settle(
    expenses: [for (final e in expenses) e.toSettlementExpense()],
    memberIds: trip.participantIds,
    rule: team.rule,
    treasurerId: team.treasurerId,
  );
}

String won(int amount) {
  final s = amount.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${amount < 0 ? '-' : ''}$b원';
}

String _dateLabel(DateTime d) {
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}.${two(l.month)}.${two(l.day)}';
}

/// 메신저로 보낼 정산 안내문.
String settlementShareText({
  required TeamView team,
  required TripView trip,
  required SettlementResult result,
}) {
  final b = StringBuffer()
    ..writeln('[${team.name}] ${trip.title} 정산 (${_dateLabel(trip.date)})')
    ..writeln('총 비용 ${won(result.total)} / ${trip.participantIds.length}명')
    ..writeln();
  for (final i in result.items) {
    b.writeln('${team.nameOf(i.userId)}: 부담 ${won(i.shareTotal)}, 결제 ${won(i.paidTotal)}');
  }
  b.writeln();
  if (result.transfers.isEmpty) {
    b.writeln('주고받을 돈이 없어요.');
  } else {
    b.writeln('송금:');
    for (final t in result.transfers) {
      b.writeln('${team.nameOf(t.from)} → ${team.nameOf(t.to)} ${won(t.amount)}');
    }
  }
  return b.toString().trimRight();
}
