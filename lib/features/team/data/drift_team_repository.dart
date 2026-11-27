import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/settlement.dart';
import '../domain/team_models.dart';
import '../domain/team_repository.dart';

/// 팀 저장소의 Drift 구현. 규칙은 메모리 구현과 같다(같은 계약 시험을 둘 다 통과한다).
class DriftTeamRepository implements TeamRepository {
  DriftTeamRepository(
    this._db, {
    this._uuid = const Uuid(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  DateTime get _utc => _now().toUtc();

  static List<String> _ids(String json) => [for (final e in jsonDecode(json) as List) e as String];

  // ── 팀 ──────────────────────────────────────────────

  List<TeamView> _groupTeams(List<TypedResult> rows) {
    final teams = <String, TeamRow>{};
    final members = <String, List<TeamMember>>{};
    for (final r in rows) {
      final t = r.readTable(_db.teams);
      teams[t.id] = t;
      final m = r.readTableOrNull(_db.teamMembers);
      final list = members.putIfAbsent(t.id, () => []);
      if (m != null) list.add(TeamMember(id: m.id, name: m.name, removed: m.deletedAt != null));
    }
    final sorted = teams.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    return [
      for (final t in sorted)
        TeamView(
          id: t.id,
          name: t.name,
          rule: t.remainderRule == 'treasurer' ? RemainderRule.treasurer : RemainderRule.payer,
          treasurerId: t.treasurerId,
          members: members[t.id] ?? const [],
        ),
    ];
  }

  JoinedSelectStatement<HasResultSet, dynamic> _teamQuery() =>
      _db.select(_db.teams).join([
        leftOuterJoin(_db.teamMembers, _db.teamMembers.teamId.equalsExp(_db.teams.id)),
      ])
        ..where(_db.teams.deletedAt.isNull())
        ..orderBy([OrderingTerm.asc(_db.teamMembers.createdAt)]);

  @override
  Stream<List<TeamView>> watchTeams() => _teamQuery().watch().map(_groupTeams);

  @override
  Stream<TeamView?> watchTeam(String id) =>
      (_teamQuery()..where(_db.teams.id.equals(id))).watch().map((rows) {
        final list = _groupTeams(rows);
        return list.isEmpty ? null : list.first;
      });

  Future<TeamRow> _team(String id) async {
    final t = await (_db.select(_db.teams)..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (t == null) throw StateError('없는 팀입니다');
    return t;
  }

  Future<Set<String>> _activeMemberIds(String teamId) async {
    final rows = await (_db.select(_db.teamMembers)
          ..where((m) => m.teamId.equals(teamId) & m.deletedAt.isNull()))
        .get();
    return {for (final m in rows) m.id};
  }

  @override
  Future<String> createTeam(String name) async {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('팀 이름을 입력해 주세요');
    final id = _uuid.v4();
    final now = _utc;
    await _db.into(_db.teams).insert(
        TeamsCompanion.insert(id: id, name: n, createdAt: now, updatedAt: now));
    return id;
  }

  @override
  Future<void> renameTeam(String id, String name) async {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('팀 이름을 입력해 주세요');
    await _team(id);
    await (_db.update(_db.teams)..where((t) => t.id.equals(id)))
        .write(TeamsCompanion(name: Value(n), updatedAt: Value(_utc)));
  }

  @override
  Future<void> setRule(String teamId, RemainderRule rule, {String? treasurerId}) async {
    await _team(teamId);
    if (rule == RemainderRule.treasurer && !(await _activeMemberIds(teamId)).contains(treasurerId)) {
      throw ArgumentError('총무는 팀 멤버여야 합니다');
    }
    await (_db.update(_db.teams)..where((t) => t.id.equals(teamId))).write(TeamsCompanion(
      remainderRule: Value(rule.name),
      treasurerId: Value(rule == RemainderRule.treasurer ? treasurerId : null),
      updatedAt: Value(_utc),
    ));
  }

  @override
  Future<String> addMember(String teamId, String name) async {
    await _team(teamId);
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError('이름을 입력해 주세요');
    final dup = await (_db.select(_db.teamMembers)
          ..where((m) => m.teamId.equals(teamId) & m.deletedAt.isNull() & m.name.equals(n)))
        .getSingleOrNull();
    if (dup != null) throw ArgumentError('같은 이름의 멤버가 이미 있어요');
    final id = _uuid.v4();
    final now = _utc;
    await _db.into(_db.teamMembers).insert(TeamMembersCompanion.insert(
        id: id, teamId: teamId, name: n, createdAt: now, updatedAt: now));
    return id;
  }

  @override
  Future<void> removeMember(String memberId) {
    return _db.transaction(() async {
      final m = await (_db.select(_db.teamMembers)
            ..where((t) => t.id.equals(memberId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (m == null) throw StateError('없는 멤버입니다');
      final now = _utc;
      await (_db.update(_db.teamMembers)..where((t) => t.id.equals(memberId)))
          .write(TeamMembersCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await (_db.update(_db.teams)
            ..where((t) => t.id.equals(m.teamId) & t.treasurerId.equals(memberId)))
          .write(TeamsCompanion(treasurerId: const Value(null), updatedAt: Value(now)));
    });
  }

  @override
  Future<void> deleteTeam(String id) {
    return _db.transaction(() async {
      await _team(id);
      final now = _utc;
      final tripIds = [
        for (final t in await (_db.select(_db.trips)..where((t) => t.teamId.equals(id))).get()) t.id,
      ];
      await (_db.update(_db.tripExpenses)..where((e) => e.tripId.isIn(tripIds)))
          .write(TripExpensesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await (_db.update(_db.trips)..where((t) => t.teamId.equals(id)))
          .write(TripsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await (_db.update(_db.teams)..where((t) => t.id.equals(id)))
          .write(TeamsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    });
  }

  // ── 출조 ────────────────────────────────────────────

  TripView _tripView(TripRow t) => TripView(
        id: t.id,
        teamId: t.teamId,
        title: t.title,
        date: t.tripDate,
        participantIds: _ids(t.participantIds),
        settledAt: t.settledAt,
      );

  Future<TripRow> _trip(String id) async {
    final t = await (_db.select(_db.trips)..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (t == null) throw StateError('없는 출조입니다');
    return t;
  }

  Future<TripRow> _openTrip(String id) async {
    final t = await _trip(id);
    if (t.settledAt != null) throw StateError('정산이 마감된 출조입니다. 다시 열어야 고칠 수 있어요');
    return t;
  }

  @override
  Stream<List<TripView>> watchTrips(String teamId) {
    final q = _db.select(_db.trips)
      ..where((t) => t.teamId.equals(teamId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.tripDate)]);
    return q.watch().map((rows) => rows.map(_tripView).toList());
  }

  @override
  Stream<TripView?> watchTrip(String id) {
    final q = _db.select(_db.trips)..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return q.watchSingleOrNull().map((r) => r == null ? null : _tripView(r));
  }

  @override
  Future<String> createTrip(String teamId, TripInput input) async {
    await _team(teamId);
    validateTripInput(input, await _activeMemberIds(teamId));
    final id = _uuid.v4();
    final now = _utc;
    await _db.into(_db.trips).insert(TripsCompanion.insert(
          id: id,
          teamId: teamId,
          title: input.title.trim(),
          tripDate: input.date.toUtc(),
          participantIds: jsonEncode(input.participantIds),
          createdAt: now,
          updatedAt: now,
        ));
    return id;
  }

  @override
  Future<void> updateTrip(String id, TripInput input) {
    return _db.transaction(() async {
      final t = await _openTrip(id);
      final expenses = await (_db.select(_db.tripExpenses)
            ..where((e) => e.tripId.equals(id) & e.deletedAt.isNull()))
          .get();
      final used = {
        for (final e in expenses) ...[e.payerId, ..._ids(e.targetIds)],
      };
      final keep = {...await _activeMemberIds(t.teamId), ..._ids(t.participantIds)};
      validateTripInput(input, keep);
      if (!used.every(input.participantIds.contains)) {
        throw ArgumentError('비용에 쓰인 참여자는 뺄 수 없어요');
      }
      await (_db.update(_db.trips)..where((r) => r.id.equals(id))).write(TripsCompanion(
        title: Value(input.title.trim()),
        tripDate: Value(input.date.toUtc()),
        participantIds: Value(jsonEncode(input.participantIds)),
        updatedAt: Value(_utc),
      ));
    });
  }

  @override
  Future<void> deleteTrip(String id) {
    return _db.transaction(() async {
      await _trip(id);
      final now = _utc;
      await (_db.update(_db.tripExpenses)..where((e) => e.tripId.equals(id)))
          .write(TripExpensesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await (_db.update(_db.trips)..where((t) => t.id.equals(id)))
          .write(TripsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    });
  }

  @override
  Future<void> setSettled(String tripId, bool settled) {
    return _db.transaction(() async {
      final t = await _trip(tripId);
      if (settled) {
        final any = await (_db.select(_db.tripExpenses)
              ..where((e) => e.tripId.equals(tripId) & e.deletedAt.isNull())
              ..limit(1))
            .get();
        if (any.isEmpty) throw ArgumentError('비용이 없는 출조는 마감할 수 없어요');
        if (t.settledAt != null) return;
      }
      final now = _utc;
      await (_db.update(_db.trips)..where((r) => r.id.equals(tripId))).write(
          TripsCompanion(settledAt: Value(settled ? now : null), updatedAt: Value(now)));
    });
  }

  // ── 비용 ────────────────────────────────────────────

  ExpenseView _expenseView(TripExpenseRow e) => ExpenseView(
        id: e.id,
        tripId: e.tripId,
        description: e.description,
        amount: e.amount,
        payerId: e.payerId,
        targetIds: _ids(e.targetIds),
      );

  @override
  Stream<List<ExpenseView>> watchExpenses(String tripId) {
    final q = _db.select(_db.tripExpenses)
      ..where((e) => e.tripId.equals(tripId) & e.deletedAt.isNull())
      ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]);
    return q.watch().map((rows) => rows.map(_expenseView).toList());
  }

  @override
  Future<String> addExpense(String tripId, ExpenseInput input) async {
    final t = await _openTrip(tripId);
    validateExpenseInput(input, _ids(t.participantIds).toSet());
    final id = _uuid.v4();
    final now = _utc;
    await _db.into(_db.tripExpenses).insert(TripExpensesCompanion.insert(
          id: id,
          tripId: tripId,
          description: input.description.trim(),
          amount: input.amount,
          payerId: input.payerId,
          targetIds: jsonEncode(input.targetIds),
          createdAt: now,
          updatedAt: now,
        ));
    return id;
  }

  Future<TripExpenseRow> _expense(String id) async {
    final e = await (_db.select(_db.tripExpenses)
          ..where((e) => e.id.equals(id) & e.deletedAt.isNull()))
        .getSingleOrNull();
    if (e == null) throw StateError('없는 비용입니다');
    return e;
  }

  @override
  Future<void> updateExpense(String id, ExpenseInput input) async {
    final e = await _expense(id);
    final t = await _openTrip(e.tripId);
    validateExpenseInput(input, _ids(t.participantIds).toSet());
    await (_db.update(_db.tripExpenses)..where((r) => r.id.equals(id))).write(TripExpensesCompanion(
      description: Value(input.description.trim()),
      amount: Value(input.amount),
      payerId: Value(input.payerId),
      targetIds: Value(jsonEncode(input.targetIds)),
      updatedAt: Value(_utc),
    ));
  }

  @override
  Future<void> deleteExpense(String id) async {
    final e = await _expense(id);
    await _openTrip(e.tripId);
    final now = _utc;
    await (_db.update(_db.tripExpenses)..where((r) => r.id.equals(id)))
        .write(TripExpensesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }
}
