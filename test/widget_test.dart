import 'package:flutter_test/flutter_test.dart';
import 'package:skillpay/main.dart';

void main() {
  testWidgets('Skillpay onboarding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SkillpayApp());
    expect(find.text('Skillpay'), findsOneWidget);
  });
}
