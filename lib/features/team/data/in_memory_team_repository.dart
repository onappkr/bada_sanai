import 'dart:async';

import '../domain/settlement.dart';
import '../domain/team_models.dart';
import '../domain/team_repository.dart';

/// 메모리 팀 저장소. 화면 미리보기·테스트용이며 규칙은 Drift 구현과 같아야 한다.
class InMemoryTeamRepository implements TeamRepository {
  InMemoryTeamRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final _changes = StreamController<void>.broadcast();
  int _seq = 0;

  final _teams = <String, _Team>{};
  final _members = <String, _Member>{};
  final _trips = <String, _Trip>{};
  final _expenses = <String, _Expense>{};

  String _id(String prefix) => '$prefix-${++_seq}';

  void _notify() => _changes.add(null);

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  // ── 팀 ──────────────────────────────────────────────

  TeamView _teamView(_Team t) => TeamView(
        id: t.id,
        name: t.name,
        rule: t.rule,
        treasurerId: t.treasurerId,
        members: [
          for (final m in _members.values)
            if (m.teamId == t.id) TeamMember(id: m.id, name: m.name, removed: m.removed),
        ],
      );

  _Team _team(String id) {
    final t = _teams[id];
    if (t == null || t.deleted) throw StateError('없는 팀입니다');
    return t;
  }

  Set<String> _activeMemberIds(String teamId) =>
      {for (final m in _members.values) if (m.teamId == teamId && !m.removed) m.id};

  @override
  Stream<List<TeamView>> watchTeams() => _watch(() {
        final list = [for (final t in _teams.values) if (!t.deleted) t]
          ..sort((a, b) => a.name.compareTo(b.name));
        return [for (final t in list) _teamView(t)];
      });

  @override
  Stream<TeamView?> watchTeam(String id) => _watch(() {
        final t = _teams[id];
        return t == null || t.deleted ? null : _teamView(t);
      });

  @override
  Future<String> createTeam(String name) async {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('팀 이름을 입력해 주세요');
    final id = _id('team');
    _teams[id] = _Team(id, n);
    _notify();
    return id;
  }

  @override
  Future<void> renameTeam(String id, String name) async {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('팀 이름을 입력해 주세요');
    _team(id).name = n;
    _notify();
  }

  @override
  Future<void> setRule(String teamId, RemainderRule rule, {String? treasurerId}) async {
    final t = _team(teamId);
    if (rule == RemainderRule.treasurer && !_activeMemberIds(teamId).contains(treasurerId)) {
      throw ArgumentError('총무는 팀 멤버여야 합니다');
    }
    t.rule = rule;
    t.treasurerId = rule == RemainderRule.treasurer ? treasurerId : null;
    _notify();
  }

  @override
  Future<String> addMember(String teamId, String name) async {
    _team(teamId);
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('이름을 입력해 주세요');
    final dup = _members.values.any((m) => m.teamId == teamId && !m.removed && m.name == n);
    if (dup) throw ArgumentError('같은 이름의 멤버가 이미 있어요');
    final id = _id('member');
    _members[id] = _Member(id, teamId, n);
    _notify();
    return id;
  }

  @override
  Future<void> removeMember(String memberId) async {
    final m = _members[memberId];
    if (m == null || m.removed) throw StateError('없는 멤버입니다');
    m.removed = true;
    final t = _teams[m.teamId];
    if (t != null && t.treasurerId == memberId) t.treasurerId = null;
    _notify();
  }

  @override
  Future<void> deleteTeam(String id) async {
    _team(id).deleted = true;
    for (final trip in _trips.values.where((t) => t.teamId == id)) {
      trip.deleted = true;
      for (final e in _expenses.values.where((e) => e.tripId == trip.id)) {
        e.deleted = true;
      }
    }
    _notify();
  }

  // ── 출조 ────────────────────────────────────────────

  TripView _tripView(_Trip t) => TripView(
        id: t.id,
        teamId: t.teamId,
        title: t.title,
        date: t.date,
        participantIds: List.unmodifiable(t.participantIds),
        settledAt: t.settledAt,
      );

  _Trip _trip(String id) {
    final t = _trips[id];
    if (t == null || t.deleted) throw StateError('없는 출조입니다');
    return t;
  }

  _Trip _openTrip(String id) {
    final t = _trip(id);
    if (t.settledAt != null) throw StateError('정산이 마감된 출조입니다. 다시 열어야 고칠 수 있어요');
    return t;
  }

  @override
  Stream<List<TripView>> watchTrips(String teamId) => _watch(() {
        final list = [for (final t in _trips.values) if (t.teamId == teamId && !t.deleted) t]
          ..sort((a, b) => b.date.compareTo(a.date));
        return [for (final t in list) _tripView(t)];
      });

  @override
  Stream<TripView?> watchTrip(String id) => _watch(() {
        final t = _trips[id];
        return t == null || t.deleted ? null : _tripView(t);
      });

  @override
  Future<String> createTrip(String teamId, TripInput input) async {
    _team(teamId);
    validateTripInput(input, _activeMemberIds(teamId));
    final id = _id('trip');
    _trips[id] = _Trip(id, teamId, input.title.trim(), input.date, [...input.participantIds]);
    _notify();
    return id;
  }

  @override
  Future<void> updateTrip(String id, TripInput input) async {
    final t = _openTrip(id);
    // 이미 비용에 쓰인 사람은 참여자에서 뺄 수 없다.
    final used = {
      for (final e in _expenses.values)
        if (e.tripId == id && !e.deleted) ...[e.payerId, ...e.targetIds],
    };
    final keep = {..._activeMemberIds(t.teamId), ...t.participantIds};
    validateTripInput(input, keep);
    if (!used.every(input.participantIds.contains)) {
      throw ArgumentError('비용에 쓰인 참여자는 뺄 수 없어요');
    }
    t
      ..title = input.title.trim()
      ..date = input.date
      ..participantIds = [...input.participantIds];
    _notify();
  }

  @override
  Future<void> deleteTrip(String id) async {
    _trip(id).deleted = true;
    for (final e in _expenses.values.where((e) => e.tripId == id)) {
      e.deleted = true;
    }
    _notify();
  }

  @override
  Future<void> setSettled(String tripId, bool settled) async {
    final t = _trip(tripId);
    if (settled) {
      if (!_expenses.values.any((e) => e.tripId == tripId && !e.deleted)) {
        throw ArgumentError('비용이 없는 출조는 마감할 수 없어요');
      }
      t.settledAt ??= _now().toUtc();
    } else {
      t.settledAt = null;
    }
    _notify();
  }

  // ── 비용 ────────────────────────────────────────────

  ExpenseView _expenseView(_Expense e) => ExpenseView(
        id: e.id,
        tripId: e.tripId,
        description: e.description,
        amount: e.amount,
        payerId: e.payerId,
        targetIds: List.unmodifiable(e.targetIds),
      );

  @override
  Stream<List<ExpenseView>> watchExpenses(String tripId) => _watch(() => [
        for (final e in _expenses.values)
          if (e.tripId == tripId && !e.deleted) _expenseView(e),
      ]);

  @override
  Future<String> addExpense(String tripId, ExpenseInput input) async {
    final t = _openTrip(tripId);
    validateExpenseInput(input, t.participantIds.toSet());
    final id = _id('expense');
    _expenses[id] = _Expense(id, tripId, input.description.trim(), input.amount, input.payerId,
        [...input.targetIds]);
    _notify();
    return id;
  }

  @override
  Future<void> updateExpense(String id, ExpenseInput input) async {
    final e = _expenses[id];
    if (e == null || e.deleted) throw StateError('없는 비용입니다');
    final t = _openTrip(e.tripId);
    validateExpenseInput(input, t.participantIds.toSet());
    e
      ..description = input.description.trim()
      ..amount = input.amount
      ..payerId = input.payerId
      ..targetIds = [...input.targetIds];
    _notify();
  }

  @override
  Future<void> deleteExpense(String id) async {
    final e = _expenses[id];
    if (e == null || e.deleted) throw StateError('없는 비용입니다');
    _openTrip(e.tripId);
    e.deleted = true;
    _notify();
  }
}

class _Team {
  _Team(this.id, this.name);
  final String id;
  String name;
  RemainderRule rule = RemainderRule.payer;
  String? treasurerId;
  bool deleted = false;
}

class _Member {
  _Member(this.id, this.teamId, this.name);
  final String id;
  final String teamId;
  final String name;
  bool removed = false;
}

class _Trip {
  _Trip(this.id, this.teamId, this.title, this.date, this.participantIds);
  final String id;
  final String teamId;
  String title;
  DateTime date;
  List<String> participantIds;
  DateTime? settledAt;
  bool deleted = false;
}

class _Expense {
  _Expense(this.id, this.tripId, this.description, this.amount, this.payerId, this.targetIds);
  final String id;
  final String tripId;
  String description;
  int amount;
  String payerId;
  List<String> targetIds;
  bool deleted = false;
}
