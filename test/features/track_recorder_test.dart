import 'dart:async';

import 'package:bada_sanai/features/tracking/domain/track_logic.dart';
import 'package:bada_sanai/features/tracking/domain/track_recorder.dart';
import 'package:bada_sanai/features/tracking/domain/tracking_ports.dart';
import 'package:test/test.dart';

final t0 = DateTime.utc(2026, 11, 27, 6);

LocationSample at(int seconds, {double northM = 0, double? acc}) => LocationSample(
      lat: 35.0 + northM / 111195,
      lng: 129.0,
      time: t0.add(Duration(seconds: seconds)),
      accuracyM: acc,
    );

class FakeRepo implements TrackRepository {
  final List<String> log = [];
  final List<LocationSample> buffered = [];
  TrackResult? finished;
  bool failFinish = false;
  bool failAddSample = false;

  @override
  Future<String> start(DateTime startedAt) async {
    log.add('start');
    return 't1';
  }

  @override
  Future<void> addSample(String trackId, LocationSample s) async {
    if (failAddSample) throw StateError('디스크 가득');
    buffered.add(s);
  }

  @override
  Future<void> finish(String trackId, TrackResult result) async {
    if (failFinish) throw StateError('저장 실패');
    log.add('finish');
    finished = result;
  }

  @override
  Future<void> discard(String trackId) async => log.add('discard');

  @override
  Stream<List<CandidateView>> watchPendingCandidates(String trackId) =>
      const Stream.empty();

  @override
  Future<String> confirmCandidate(String candidateId, String name) async => 'p';

  @override
  Future<void> dismissCandidate(String candidateId) async {}

  @override
  Future<List<InterruptedTrack>> findInterrupted() async => const [];

  @override
  Future<List<LocationSample>> bufferedSamples(String trackId) async => const [];
}

class FakeSource implements LocationSource {
  final controller = StreamController<LocationSample>.broadcast();

  @override
  Stream<LocationSample> watch() => controller.stream;
}

void main() {
  late FakeRepo repo;
  late FakeSource source;
  late List<RecorderState> states;
  late TrackRecorder recorder;

  setUp(() {
    repo = FakeRepo();
    source = FakeSource();
    states = [];
    recorder = TrackRecorder(
      repository: repo,
      source: source,
      onChanged: states.add,
      clock: () => t0,
    );
  });
  tearDown(() => recorder.dispose());

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  test('시작하면 기록 중이 되고 점이 쌓이며 거리·시간이 갱신된다', () async {
    await recorder.start();
    expect(recorder.state.phase, RecorderPhase.recording);
    expect(recorder.state.trackId, 't1');

    source.controller.add(at(0));
    source.controller.add(at(60, northM: 100));
    await pump();

    expect(repo.buffered.length, 2);
    expect(recorder.state.distanceM, closeTo(100, 1));
    expect(recorder.state.elapsed, const Duration(seconds: 60));
    expect(recorder.state.last, isNotNull);
  });

  test('걸러진 점은 저장소에도 가지 않는다', () async {
    await recorder.start();
    source.controller.add(at(0, acc: 90));
    source.controller.add(at(1));
    await pump();
    expect(repo.buffered.length, 1);
  });

  test('이미 기록 중일 때 start는 아무것도 하지 않는다', () async {
    await recorder.start();
    await recorder.start();
    expect(repo.log.where((e) => e == 'start').length, 1);
  });

  test('일시정지 중 점은 무시하고, 재개하면 다시 받는다', () async {
    await recorder.start();
    source.controller.add(at(0));
    await pump();
    recorder.pause();
    expect(recorder.state.phase, RecorderPhase.paused);
    source.controller.add(at(60, northM: 50));
    await pump();
    expect(repo.buffered.length, 1);

    recorder.resume();
    source.controller.add(at(120, northM: 50));
    await pump();
    expect(repo.buffered.length, 2);
  });

  test('종료하면 결과를 저장하고 대기 상태로 돌아가며 트랙 id를 준다', () async {
    await recorder.start();
    for (var i = 0; i <= 11; i++) {
      source.controller.add(at(i * 60));
    }
    await pump();

    final id = await recorder.stop();
    expect(id, 't1');
    expect(repo.log, ['start', 'finish']);
    expect(repo.finished!.candidates.length, 1); // 11분 머묾
    expect(recorder.state.phase, RecorderPhase.idle);
  });

  test('기록 중이 아닐 때 stop은 null', () async {
    expect(await recorder.stop(), isNull);
    expect(repo.log, isEmpty);
  });

  test('저장에 실패하면 예외를 던지되 기록 중 상태로 돌아가 다시 시도할 수 있다', () async {
    await recorder.start();
    source.controller.add(at(0));
    await pump();

    repo.failFinish = true;
    await expectLater(recorder.stop(), throwsStateError);
    expect(recorder.state.phase, RecorderPhase.recording);
    expect(recorder.state.error, contains('저장하지 못했어요'));

    repo.failFinish = false;
    expect(await recorder.stop(), 't1');
  });

  test('임시 점 저장이 실패해도 기록은 계속된다', () async {
    await recorder.start();
    repo.failAddSample = true;
    source.controller.add(at(0));
    source.controller.add(at(60, northM: 80));
    await pump();
    expect(recorder.state.distanceM, closeTo(80, 1));
    expect(recorder.state.phase, RecorderPhase.recording);
  });

  test('위치 오류는 상태에 표시되고 이후 점을 받으면 지워진다', () async {
    await recorder.start();
    source.controller.addError(StateError('권한 없음'));
    await pump();
    expect(recorder.state.error, contains('위치를 받을 수 없어요'));

    source.controller.add(at(0));
    await pump();
    expect(recorder.state.error, isNull);
  });

  test('버리면 저장소에서도 지우고 대기 상태가 된다', () async {
    await recorder.start();
    await recorder.discard();
    expect(repo.log, ['start', 'discard']);
    expect(recorder.state.phase, RecorderPhase.idle);
  });
}
