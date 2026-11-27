import 'package:bada_sanai/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱이 시작된다', (tester) async {
    await tester.pumpWidget(const BadaSanaiApp());
    expect(find.text('바다 사나이'), findsOneWidget);
  });
}
