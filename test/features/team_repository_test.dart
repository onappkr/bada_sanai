import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/team/data/drift_team_repository.dart';
import 'package:bada_sanai/features/team/data/in_memory_team_repository.dart';
import 'package:bada_sanai/features/team/domain/settlement.dart';
import 'package:bada_sanai/features/team/domain/settlement_summary.dart';
import 'package:bada_sanai/features/team/domain/team_models.dart';
import 'package:bada_sanai/features/team/domain/team_repository.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

/// 메모리·Drift 두 구현이 같은 규칙을 지키는지 같은 시험으로 확인한다.
void main() {
  contract('메모리', () async => (InMemoryTeamRepository(), () async {}));
  contract('Drift', () async {
    final db = AppDatabase(NativeDatabase.memory());
    return (DriftTeamRepository(db) as TeamRepository, () => db.close());
  });

  group('정산 요약', summaryTests);
}

typedef Made = (TeamRepository, Future<void> Function());

void contract(String label, Future<Made> Function() create) {
  group('팀 저장소($label)', () {
    late TeamRepository repo;
    late Future<void> Function() close;
    final day = DateTime(2026, 11, 27);

    setUp(() async {
      final made = await create();
      repo = made.$1;
      close = made.$2;
    });
    tearDown(() => close());

    /// 팀을 만들고 멤버 이름 → id 맵을 돌려준다.
    Future<(String, Map<String, String>)> teamWith(List<String> names) async {
      final t = await repo.createTeam('바다팀');
      final ids = <String, String>{};
      for (final n in names) {
        ids[n] = await repo.addMember(t, n);
      }
      return (t, ids);
    }

    Future<String> tripOf(String team, Iterable<String> participants) =>
        repo.createTrip(team, TripInput(title: '가덕도', date: day, participantIds: [...participants]));

    test('팀을 만들면 목록에 이름순으로 나온다', () async {
      await repo.createTeam('나팀');
      await repo.createTeam('가팀');
      expect((await repo.watchTeams().first).map((t) => t.name), ['가팀', '나팀']);
    });

    test('빈 이름은 거부한다', () async {
      await expectLater(repo.createTeam('  '), throwsArgumentError);
      final (t, _) = await teamWith(['철수']);
      await expectLater(repo.renameTeam(t, ''), throwsArgumentError);
      await expectLater(repo.addMember(t, ' '), throwsArgumentError);
    });

    test('같은 이름의 멤버는 둘 수 없고, 뺀 뒤에는 다시 넣을 수 있다', () async {
      final (t, ids) = await teamWith(['철수']);
      await expectLater(repo.addMember(t, '철수'), throwsArgumentError);
      await repo.removeMember(ids['철수']!);
      await repo.addMember(t, '철수');
      final team = (await repo.watchTeam(t).first)!;
      expect(team.activeMembers.map((m) => m.name), ['철수']);
      expect(team.members.length, 2); // 뺀 멤버의 행은 남는다
    });

    test('뺀 멤버의 이름은 계속 찾을 수 있다', () async {
      final (t, ids) = await teamWith(['철수', '영희']);
      await repo.removeMember(ids['철수']!);
      final team = (await repo.watchTeam(t).first)!;
      expect(team.nameOf(ids['철수']!), '철수');
      expect(team.activeMembers.map((m) => m.name), ['영희']);
    });

    test('끝전 규칙: 총무는 활성 멤버여야 하고, 총무를 빼면 지정이 풀린다', () async {
      final (t, ids) = await teamWith(['철수', '영희']);
      await expectLater(repo.setRule(t, RemainderRule.treasurer), throwsArgumentError);
      await expectLater(repo.setRule(t, RemainderRule.treasurer, treasurerId: 'ghost'), throwsArgumentError);
      await repo.setRule(t, RemainderRule.treasurer, treasurerId: ids['영희']);
      var team = (await repo.watchTeam(t).first)!;
      expect(team.rule, RemainderRule.treasurer);
      expect(team.treasurerId, ids['영희']);

      await repo.removeMember(ids['영희']!);
      team = (await repo.watchTeam(t).first)!;
      expect(team.treasurerId, isNull);

      await repo.setRule(t, RemainderRule.payer);
      expect((await repo.watchTeam(t).first)!.rule, RemainderRule.payer);
    });

    test('출조: 참여자는 팀의 활성 멤버만, 최소 한 명, 이름 필수', () async {
      final (t, ids) = await teamWith(['철수']);
      await expectLater(repo.createTrip(t, TripInput(title: '', date: day, participantIds: [ids['철수']!])), throwsArgumentError);
      await expectLater(repo.createTrip(t, TripInput(title: 'a', date: day, participantIds: const [])), throwsArgumentError);
      await expectLater(repo.createTrip(t, TripInput(title: 'a', date: day, participantIds: const ['ghost'])), throwsArgumentError);
      await expectLater(
          repo.createTrip(t, TripInput(title: 'a', date: day, participantIds: [ids['철수']!, ids['철수']!])),
          throwsArgumentError);
    });

    test('출조 목록은 최근 날짜가 먼저다', () async {
      final (t, ids) = await teamWith(['철수']);
      final p = [ids['철수']!];
      await repo.createTrip(t, TripInput(title: '옛날', date: DateTime(2026, 1, 1), participantIds: p));
      await repo.createTrip(t, TripInput(title: '최근', date: DateTime(2026, 11, 1), participantIds: p));
      expect((await repo.watchTrips(t).first).map((e) => e.title), ['최근', '옛날']);
    });

    test('비용: 결제자·대상자는 출조 참여자여야 하고 금액은 1원 이상', () async {
      final (t, ids) = await teamWith(['철수', '영희', '민수']);
      final trip = await tripOf(t, [ids['철수']!, ids['영희']!]);
      ExpenseInput e({int amount = 1000, String? payer, List<String>? targets}) => ExpenseInput(
            description: '기름값',
            amount: amount,
            payerId: payer ?? ids['철수']!,
            targetIds: targets ?? [ids['철수']!, ids['영희']!],
          );
      await expectLater(repo.addExpense(trip, e(amount: 0)), throwsArgumentError);
      await expectLater(repo.addExpense(trip, e(payer: ids['민수'])), throwsArgumentError);
      await expectLater(repo.addExpense(trip, e(targets: [ids['민수']!])), throwsArgumentError);
      await expectLater(repo.addExpense(trip, e(targets: const [])), throwsArgumentError);
      await expectLater(
          repo.addExpense(trip, ExpenseInput(description: ' ', amount: 1, payerId: ids['철수']!, targetIds: [ids['철수']!])),
          throwsArgumentError);
      await repo.addExpense(trip, e());
      expect(await repo.watchExpenses(trip).first, hasLength(1));
    });

    test('비용을 고치고 지우면 목록에 반영된다', () async {
      final (t, ids) = await teamWith(['철수', '영희']);
      final trip = await tripOf(t, ids.values);
      final id = await repo.addExpense(
          trip, ExpenseInput(description: '미끼', amount: 5000, payerId: ids['철수']!, targetIds: ids.values.toList()));
      await repo.updateExpense(
          id, ExpenseInput(description: '미끼값', amount: 7000, payerId: ids['영희']!, targetIds: [ids['영희']!]));
      final e = (await repo.watchExpenses(trip).first).single;
      expect((e.description, e.amount, e.payerId), ('미끼값', 7000, ids['영희']));
      await repo.deleteExpense(id);
      expect(await repo.watchExpenses(trip).first, isEmpty);
      await expectLater(repo.deleteExpense(id), throwsStateError);
    });

    test('비용에 쓰인 참여자는 출조에서 뺄 수 없다', () async {
      final (t, ids) = await teamWith(['철수', '영희']);
      final trip = await tripOf(t, ids.values);
      await repo.addExpense(
          trip, ExpenseInput(description: '밥', amount: 1000, payerId: ids['철수']!, targetIds: ids.values.toList()));
      await expectLater(
          repo.updateTrip(trip, TripInput(title: '가덕도', date: day, participantIds: [ids['철수']!])),
          throwsArgumentError);
      // 비용이 없어진 뒤에는 뺄 수 있다.
      final e = (await repo.watchExpenses(trip).first).single;
      await repo.deleteExpense(e.id);
      await repo.updateTrip(trip, TripInput(title: '가덕도', date: day, participantIds: [ids['철수']!]));
      expect((await repo.watchTrip(trip).first)!.participantIds, [ids['철수']]);
    });

    test('마감: 비용이 없으면 못 하고, 마감하면 고칠 수 없으며, 다시 열면 고칠 수 있다', () async {
      final (t, ids) = await teamWith(['철수']);
      final trip = await tripOf(t, ids.values);
      await expectLater(repo.setSettled(trip, true), throwsArgumentError);
      final input = ExpenseInput(description: '밥', amount: 1000, payerId: ids['철수']!, targetIds: ids.values.toList());
      final eid = await repo.addExpense(trip, input);

      await repo.setSettled(trip, true);
      expect((await repo.watchTrip(trip).first)!.settled, isTrue);
      await expectLater(repo.addExpense(trip, input), throwsStateError);
      await expectLater(repo.updateExpense(eid, input), throwsStateError);
      await expectLater(repo.deleteExpense(eid), throwsStateError);
      await expectLater(
          repo.updateTrip(trip, TripInput(title: '바꿈', date: day, participantIds: ids.values.toList())),
          throwsStateError);

      await repo.setSettled(trip, false);
      expect((await repo.watchTrip(trip).first)!.settled, isFalse);
      await repo.addExpense(trip, input);
    });

    test('출조를 지우면 비용도 함께 사라진다', () async {
      final (t, ids) = await teamWith(['철수']);
      final trip = await tripOf(t, ids.values);
      await repo.addExpense(
          trip, ExpenseInput(description: '밥', amount: 1000, payerId: ids['철수']!, targetIds: ids.values.toList()));
      await repo.deleteTrip(trip);
      expect(await repo.watchTrip(trip).first, isNull);
      expect(await repo.watchTrips(t).first, isEmpty);
      expect(await repo.watchExpenses(trip).first, isEmpty);
    });

    test('팀을 지우면 팀·출조가 사라지고 이후 변경은 StateError', () async {
      final (t, ids) = await teamWith(['철수']);
      final trip = await tripOf(t, ids.values);
      await repo.deleteTeam(t);
      expect(await repo.watchTeams().first, isEmpty);
      expect(await repo.watchTeam(t).first, isNull);
      expect(await repo.watchTrip(trip).first, isNull);
      await expectLater(repo.addMember(t, '영희'), throwsStateError);
    });
  });
}

void summaryTests() {
  const team = TeamView(
    id: 't',
    name: '바다팀',
    members: [
      TeamMember(id: 'a', name: '철수'),
      TeamMember(id: 'b', name: '영희'),
      TeamMember(id: 'c', name: '민수'),
    ],
  );
  final trip = TripView(
      id: 'x', teamId: 't', title: '가덕도', date: DateTime(2026, 11, 27), participantIds: const ['a', 'b', 'c']);

  ExpenseView e(String id, int amount, String payer, List<String> targets) => ExpenseView(
      id: id, tripId: 'x', description: id, amount: amount, payerId: payer, targetIds: targets);

  test('비용이 없으면 null', () {
    expect(settleTrip(team: team, trip: trip, expenses: const []), isNull);
  });

  test('세 명이 나누고 끝전은 결제자가 부담하며 송금 목록이 나온다', () {
    final r = settleTrip(team: team, trip: trip, expenses: [
      e('기름', 10000, 'a', ['a', 'b', 'c']),
    ])!;
    expect(r.total, 10000);
    // 10000/3 = 3333, 끝전 1원은 결제자 a가 부담 → a 3334, b 3333, c 3333
    expect(r.items.firstWhere((i) => i.userId == 'a').shareTotal, 3334);
    expect(r.transfers.map((t) => (t.from, t.to, t.amount)).toSet(), {('b', 'a', 3333), ('c', 'a', 3333)});
  });

  test('돈 표기', () {
    expect(won(0), '0원');
    expect(won(999), '999원');
    expect(won(1234567), '1,234,567원');
    expect(won(-3000), '-3,000원');
  });

  test('공유 문구에 이름·금액·송금이 들어간다', () {
    final r = settleTrip(team: team, trip: trip, expenses: [e('기름', 10000, 'a', ['a', 'b', 'c'])])!;
    final text = settlementShareText(team: team, trip: trip, result: r);
    expect(text, contains('[바다팀] 가덕도 정산 (2026.11.27)'));
    expect(text, contains('총 비용 10,000원 / 3명'));
    expect(text, contains('영희 → 철수 3,333원'));
  });

  test('주고받을 돈이 없으면 그렇게 안내한다', () {
    final r = settleTrip(team: team, trip: trip, expenses: [e('혼자', 1000, 'a', ['a'])])!;
    expect(settlementShareText(team: team, trip: trip, result: r), contains('주고받을 돈이 없어요'));
  });
}
