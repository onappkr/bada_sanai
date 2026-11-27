import 'dart:async';

import '../../point/domain/point_models.dart';
import '../../point/domain/point_repository.dart';
import '../domain/track_logic.dart';
import '../domain/tracking_ports.dart';

/// 메모리 트랙 저장소. 미리보기·테스트용이며 확정한 후보는 [PointRepository]에 저장한다.
class InMemoryTrackRepository implements TrackRepository {
  InMemoryTrackRepository(this._points);

  final PointRepository _points;
  final Map<String, List<_Candidate>> _candidates = {};
  final _changes = StreamController<void>.broadcast();
  int _seq = 0;

  /// 기록 중인 트랙의 시작 시각과 임시 버퍼.
  final Map<String, DateTime> _recordingStart = {};
  final Map<String, List<LocationSample>> _buffer = {};

  @override
  Future<String> start(DateTime startedAt) async {
    final id = 'trk-${++_seq}';
    _recordingStart[id] = startedAt;
    _buffer[id] = [];
    return id;
  }

  @override
  Future<void> addSample(String trackId, LocationSample sample) async {
    _buffer[trackId]?.add(sample);
  }

  @override
  Future<List<InterruptedTrack>> findInterrupted() async => [
        for (final e in _recordingStart.entries)
          InterruptedTrack(
              id: e.key, startedAt: e.value, sampleCount: _buffer[e.key]?.length ?? 0),
      ]..sort((a, b) => a.startedAt.compareTo(b.startedAt));

  @override
  Future<List<LocationSample>> bufferedSamples(String trackId) async =>
      List.of(_buffer[trackId] ?? const []);

  final Map<String, SavedTrack> _saved = {};

  List<SavedTrack> _savedList() =>
      _saved.values.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  Stream<List<SavedTrack>> watchSavedTracks() async* {
    yield _savedList();
    await for (final _ in _changes.stream) {
      yield _savedList();
    }
  }

  @override
  Stream<SavedTrack?> watchSavedTrack(String trackId) async* {
    yield _saved[trackId];
    await for (final _ in _changes.stream) {
      yield _saved[trackId];
    }
  }

  @override
  Future<void> finish(String trackId, TrackResult result) async {
    _recordingStart.remove(trackId);
    _buffer.remove(trackId);
    _saved[trackId] = SavedTrack(
      id: trackId,
      startedAt: result.startedAt,
      endedAt: result.endedAt,
      distanceM: result.distanceM,
      encodedPolyline: result.encodedPolyline,
    );
    _candidates[trackId] = [
      for (final c in result.candidates)
        _Candidate('cand-${++_seq}', trackId, c.lat, c.lng, c.dwell),
    ];
    _changes.add(null);
  }

  @override
  Future<void> discard(String trackId) async {
    _saved.remove(trackId);
    _recordingStart.remove(trackId);
    _buffer.remove(trackId);
    _candidates.remove(trackId);
    _changes.add(null);
  }

  List<CandidateView> _pending(String trackId) => [
        for (final c in _candidates[trackId] ?? const <_Candidate>[])
          if (c.pending)
            CandidateView(
                id: c.id, trackId: c.trackId, lat: c.lat, lng: c.lng, dwell: c.dwell),
      ];

  @override
  Stream<List<CandidateView>> watchPendingCandidates(String trackId) async* {
    yield _pending(trackId);
    await for (final _ in _changes.stream) {
      yield _pending(trackId);
    }
  }

  _Candidate? _find(String id) {
    for (final list in _candidates.values) {
      for (final c in list) {
        if (c.id == id && c.pending) return c;
      }
    }
    return null;
  }

  @override
  Future<String> confirmCandidate(String candidateId, String name) async {
    final c = _find(candidateId);
    if (c == null) throw StateError('확정할 수 있는 후보가 아닙니다: $candidateId');
    final id = await _points.create(PointInput(
      name: name,
      lat: c.lat,
      lng: c.lng,
      source: PointSource.auto,
    ));
    c.pending = false;
    _changes.add(null);
    return id;
  }

  @override
  Future<void> dismissCandidate(String candidateId) async {
    _find(candidateId)?.pending = false;
    _changes.add(null);
  }
}

class _Candidate {
  _Candidate(this.id, this.trackId, this.lat, this.lng, this.dwell);

  final String id;
  final String trackId;
  final double lat;
  final double lng;
  final Duration dwell;
  bool pending = true;
}

/// 미리보기용 위치 가짜. 실제 시간은 1초마다 한 번 흐르지만 측정 시각은 1분씩 건너뛰어
/// (10분 머무름 같은) 긴 구간을 빨리 보여 준다.
class SimulatedLocationSource implements LocationSource {
  SimulatedLocationSource({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  @override
  Stream<LocationSample> watch() async* {
    final start = _clock();
    var minute = 0;
    // 영도 방파제 쪽: 먼저 걷다가(~7분) 한 자리에 머문다.
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 1));
      final walking = minute < 7;
      final lat = 35.0779 + (walking ? minute * 0.0006 : 7 * 0.0006) + (minute % 2) * 0.00001;
      yield LocationSample(
        lat: lat,
        lng: 129.0868 + (walking ? minute * 0.0003 : 7 * 0.0003),
        time: start.add(Duration(minutes: minute)),
        accuracyM: 8,
        speedMps: walking ? 1.3 : 0,
      );
      minute++;
    }
  }
}
