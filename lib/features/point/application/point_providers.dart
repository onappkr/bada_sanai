import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart' show databaseProvider;
import '../data/drift_point_repository.dart';
import '../domain/point_models.dart';
import '../domain/point_repository.dart';

final pointRepositoryProvider = Provider<PointRepository>(
  (ref) => DriftPointRepository(ref.watch(databaseProvider)),
);

final pointsProvider = StreamProvider.autoDispose<List<PointView>>(
  (ref) => ref.watch(pointRepositoryProvider).watchAll(),
);

final pointProvider =
    StreamProvider.autoDispose.family<PointView?, String>((ref, id) {
  return ref.watch(pointRepositoryProvider).watchOne(id);
});
