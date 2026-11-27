import 'dart:async';

import 'track_logic.dart';
import 'tracking_ports.dart';

enum RecorderPhase { idle, recording, paused, saving }

class RecorderState {
  const RecorderState({
    this.phase = RecorderPhase.idle,
    this.trackId,
    this.elapsed = Duration.zero,
    this.distanceM = 0,
    this.last,
    this.error,
  });

  final RecorderPhase phase;
  final String? trackId;
  final Duration elapsed;
  final double distanceM;
  final LocationSample? last;

  /// 위치를 받지 못하는 등의 문제. 사용자에게 보여 준다.
  final String? error;

  bool get active => phase == RecorderPhase.recording || phase == RecorderPhase.paused;
}

/// 경로 기록 한 판을 이끈다: 위치 원천을 구독해 [TrackSession]에 쌓고 저장소에 남긴다.
/// 프레임워크에 묶이지 않아 테스트할 수 있다.
class TrackRecorder {
  TrackRecorder({
    required this.repository,
    required this.source,
    required this.onChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final TrackRepository repository;
  final LocationSource source;
  final void Function(RecorderState) onChanged;
  final DateTime Function() _clock;

  RecorderState _state = const RecorderState();
  TrackSession? _session;
  StreamSubscription<LocationSample>? _sub;

  RecorderState get state => _state;

  void _emit(RecorderState s) {
    _state = s;
    onChanged(s);
  }

  /// 기록을 시작한다. 이미 기록 중이면 아무것도 하지 않는다.
  Future<void> start() async {
    if (_state.phase != RecorderPhase.idle) return;
    final startedAt = _clock();
    final trackId = await repository.start(startedAt);
    _session = TrackSession(startedAt: startedAt);
    _emit(RecorderState(phase: RecorderPhase.recording, trackId: trackId));
    _sub = source.watch().listen(
          _onSample,
          onError: (Object e) => _emit(_copy(error: '위치를 받을 수 없어요: $e')),
        );
  }

  void _onSample(LocationSample s) {
    final session = _session;
    final id = _state.trackId;
    if (session == null || id == null || !session.add(s)) return;
    // 저장 실패가 기록을 멈추지는 않는다(메모리의 세션이 기준).
    unawaited(repository.addSample(id, s).catchError((Object _) {}));
    _emit(_copy(
      elapsed: session.elapsed,
      distanceM: session.distanceM,
      last: s,
      clearError: true,
    ));
  }

  void pause() {
    if (_state.phase != RecorderPhase.recording) return;
    _session!.paused = true;
    _emit(_copy(phase: RecorderPhase.paused));
  }

  void resume() {
    if (_state.phase != RecorderPhase.paused) return;
    _session!.paused = false;
    _emit(_copy(phase: RecorderPhase.recording));
  }

  /// 기록을 끝내고 저장한다. 저장한 트랙 id를 돌려준다. 기록 중이 아니면 null.
  Future<String?> stop() async {
    if (!_state.active) return null;
    final id = _state.trackId!;
    final session = _session!;
    await _sub?.cancel();
    _sub = null;
    _emit(_copy(phase: RecorderPhase.saving));
    try {
      await repository.finish(id, session.finish());
    } catch (e) {
      // 저장에 실패해도 점이 사라지지 않게 기록 중 상태로 되돌려 다시 시도하게 한다.
      _sub = source.watch().listen(_onSample);
      _emit(_copy(phase: RecorderPhase.recording, error: '저장하지 못했어요: $e'));
      rethrow;
    }
    _session = null;
    _emit(const RecorderState());
    return id;
  }

  /// 기록을 버린다.
  Future<void> discard() async {
    final id = _state.trackId;
    await _sub?.cancel();
    _sub = null;
    _session = null;
    _emit(const RecorderState());
    if (id != null) await repository.discard(id);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  RecorderState _copy({
    RecorderPhase? phase,
    Duration? elapsed,
    double? distanceM,
    LocationSample? last,
    String? error,
    bool clearError = false,
  }) =>
      RecorderState(
        phase: phase ?? _state.phase,
        trackId: _state.trackId,
        elapsed: elapsed ?? _state.elapsed,
        distanceM: distanceM ?? _state.distanceM,
        last: last ?? _state.last,
        error: clearError ? null : (error ?? _state.error),
      );
}
