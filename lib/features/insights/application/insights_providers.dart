import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catch_log/application/catch_log_providers.dart';
import '../../catch_log/domain/catch_log_models.dart';

/// 내 모든 일지(분석 화면용). 일지가 바뀌면 다시 계산된다.
final insightLogsProvider = StreamProvider.autoDispose<List<CatchLogView>>(
  (ref) => ref.watch(catchLogRepositoryProvider).watchAll(),
);
