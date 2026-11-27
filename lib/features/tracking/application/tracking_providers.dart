import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_track_repository.dart';
import '../data/geolocator_location_source.dart';
import '../domain/track_recorder.dart';
import '../domain/tracking_ports.dart';

final trackRepositoryProvider = Provider<TrackRepository>(
  (ref) => DriftTrackRepository(ref.watch(databaseProvider)),
);

final locationSourceProvider =
    Provider<LocationSource>((ref) => const GeolocatorLocationSource());

/// 경로 기록 상태. 화면을 벗어나도 기록은 이어지도록 앱 전체에서 하나만 둔다.
class TrackingController extends Notifier<RecorderState> {
  late final TrackRecorder _recorder;

  @override
  RecorderState build() {
    _recorder = TrackRecorder(
      repository: ref.read(trackRepositoryProvider),
      source: ref.read(locationSourceProvider),
      onChanged: (s) => state = s,
    );
    ref.onDispose(_recorder.dispose);
    return const RecorderState();
  }

  Future<void> start() => _recorder.start();
  void pause() => _recorder.pause();
  void resume() => _recorder.resume();
  Future<String?> stop() => _recorder.stop();
  Future<void> discard() => _recorder.discard();
}

final trackingProvider =
    NotifierProvider<TrackingController, RecorderState>(TrackingController.new);

final pendingCandidatesProvider = StreamProvider.autoDispose
    .family<List<CandidateView>, String>((ref, trackId) {
  return ref.watch(trackRepositoryProvider).watchPendingCandidates(trackId);
});
