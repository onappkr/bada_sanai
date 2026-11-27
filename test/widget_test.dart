import 'package:bada_sanai/app/app.dart';
import 'package:bada_sanai/core/db/app_database.dart';
import 'package:bada_sanai/features/catch_log/application/catch_log_providers.dart';
import 'package:bada_sanai/features/settings/application/settings_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('홈이 열리고 일지 탭으로 이동한다', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        initialOnboardingDoneProvider.overrideWithValue(true),
      ],
      child: const BadaSanaiApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('S03'), findsOneWidget);

    await tester.tap(find.text('일지'));
    await tester.pumpAndSettle();
    expect(find.text('기록이 없습니다. 첫 조행기를 남겨 보세요.'), findsOneWidget);
  });
}
