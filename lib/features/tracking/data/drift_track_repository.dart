import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../point/domain/point_models.dart' show validatePointInput;
import '../domain/track_logic.dart';
import '../domain/tracking_ports.dart';

class DriftTrackRepository implements TrackRepository {
  DriftTrackRepository(
    this._db, {
    this._uuid = const Uuid(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Future<String> start(DateTime startedAt) async {
    final id = _uuid.v4();
    await _db.into(_db.tracks).insert(TracksCompanion.insert(
          id: id,
          startedAt: startedAt.toUtc(),
          status: TrackStatus.recording,
          updatedAt: _now().toUtc(),
        ));
    return id;
  }

  @override
  Future<void> addSample(String trackId, LocationSample s) =>
      _db.into(_db.trackPoints).insert(TrackPointsCompanion.insert(
            trackId: trackId,
            lat: s.lat,
            lng: s.lng,
            accuracyM: Value(s.accuracyM),
            speedMps: Value(s.speedMps),
            recordedAt: s.time.toUtc(),
          ));

  @override
  Future<void> finish(String trackId, TrackResult r) {
    return _db.transaction(() async {
      final updated = await (_db.update(_db.tracks)..where((t) => t.id.equals(trackId)))
          .write(TracksCompanion(
        endedAt: Value(r.endedAt.toUtc()),
        distanceM: Value(r.distanceM),
        encodedPolyline: Value(r.encodedPolyline),
        status: const Value(TrackStatus.saved),
        updatedAt: Value(_now().toUtc()),
      ));
      if (updated == 0) throw StateError('기록을 찾을 수 없습니다: $trackId');
      // 임시 버퍼는 단순화한 경로가 저장됐으니 지운다.
      await (_db.delete(_db.trackPoints)..where((t) => t.trackId.equals(trackId))).go();
      for (final c in r.candidates) {
        await _db.into(_db.pointCandidates).insert(PointCandidatesCompanion.insert(
              id: _uuid.v4(),
              trackId: trackId,
              lat: c.lat,
              lng: c.lng,
              dwellSec: c.dwell.inSeconds,
              status: CandidateStatus.pending,
            ));
      }
    });
  }

  @override
  Future<void> discard(String trackId) {
    return _db.transaction(() async {
      await (_db.update(_db.tracks)..where((t) => t.id.equals(trackId))).write(
        TracksCompanion(
          status: const Value(TrackStatus.discarded),
          updatedAt: Value(_now().toUtc()),
        ),
      );
      await (_db.delete(_db.trackPoints)..where((t) => t.trackId.equals(trackId))).go();
    });
  }

  @override
  Stream<List<CandidateView>> watchPendingCandidates(String trackId) {
    final q = _db.select(_db.pointCandidates)
      ..where((t) =>
          t.trackId.equals(trackId) & t.status.equalsValue(CandidateStatus.pending))
      ..orderBy([(t) => OrderingTerm.desc(t.dwellSec)]);
    return q.watch().map((rows) => [
          for (final r in rows)
            CandidateView(
              id: r.id,
              trackId: r.trackId,
              lat: r.lat,
              lng: r.lng,
              dwell: Duration(seconds: r.dwellSec),
            ),
        ]);
  }

  @override
  Future<String> confirmCandidate(String candidateId, String name) {
    return _db.transaction(() async {
      final c = await (_db.select(_db.pointCandidates)
            ..where((t) =>
                t.id.equals(candidateId) &
                t.status.equalsValue(CandidateStatus.pending)))
          .getSingleOrNull();
      if (c == null) throw StateError('확정할 수 있는 후보가 아닙니다: $candidateId');
      final err = validatePointInput(name: name, lat: c.lat, lng: c.lng);
      if (err != null) throw ArgumentError(err);

      final now = _now().toUtc();
      final pointId = _uuid.v4();
      await _db.into(_db.points).insert(PointsCompanion.insert(
            id: pointId,
            name: name.trim(),
            lat: c.lat,
            lng: c.lng,
            source: PointSource.auto,
            createdAt: now,
            updatedAt: now,
          ));
      await (_db.update(_db.pointCandidates)..where((t) => t.id.equals(candidateId)))
          .write(const PointCandidatesCompanion(status: Value(CandidateStatus.saved)));
      return pointId;
    });
  }

  @override
  Future<void> dismissCandidate(String candidateId) =>
      (_db.update(_db.pointCandidates)..where((t) => t.id.equals(candidateId)))
          .write(const PointCandidatesCompanion(status: Value(CandidateStatus.discarded)));
}
