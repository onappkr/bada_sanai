import 'package:bada_sanai/app/app.dart';
import 'package:bada_sanai/features/catch_log/application/catch_log_providers.dart';
import 'package:bada_sanai/features/catch_log/data/in_memory_catch_log_repository.dart';
import 'package:bada_sanai/features/point/application/point_providers.dart';
import 'package:bada_sanai/features/point/data/in_memory_point_repository.dart';
import 'package:bada_sanai/features/settings/application/settings_providers.dart';
import 'package:bada_sanai/features/tracking/application/tracking_providers.dart';
import 'package:bada_sanai/features/tracking/data/in_memory_tracking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// 위젯 테스트는 가짜 시계 위에서 돌아서 실제 DB(SQLite)의 비동기 응답이 오지 않는다.
/// 그러면 화면이 로딩 표시만 도는 채로 남아 `pumpAndSettle`이 기본 10분을 기다린 뒤 실패한다.
/// 그래서 화면 시험은 메모리 저장소로 하고(DB 자체는 저장소 테스트가 따로 다룬다),
/// 대기 시간도 짧게 제한해 문제가 생겨도 오래 매달리지 않게 한다.
Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );

List<Override> memoryOverrides({required bool onboardingDone}) {
  final points = InMemoryPointRepository();
  return [
    initialOnboardingDoneProvider.overrideWithValue(onboardingDone),
    catchLogRepositoryProvider.overrideWithValue(InMemoryCatchLogRepository()),
    pointRepositoryProvider.overrideWithValue(points),
    trackRepositoryProvider.overrideWithValue(InMemoryTrackRepository(points)),
  ];
}

void main() {
  testWidgets('홈이 열리고 일지 탭으로 이동한다', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: memoryOverrides(onboardingDone: true),
      child: const BadaSanaiApp(),
    ));
    await settle(tester);
    expect(find.text('경로 기록 시작'), findsOneWidget);

    await tester.tap(find.text('일지'));
    await settle(tester);
    expect(find.text('기록이 없습니다. 첫 조행기를 남겨 보세요.'), findsOneWidget);
  });

  testWidgets('처음 실행이면 홈 대신 온보딩이 열린다', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: memoryOverrides(onboardingDone: false),
      child: const BadaSanaiApp(),
    ));
    await settle(tester);
    expect(find.text('조행기를 남겨요'), findsOneWidget);
    expect(find.text('경로 기록 시작'), findsNothing);
  });
}
