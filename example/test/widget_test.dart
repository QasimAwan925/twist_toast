import 'package:flutter_test/flutter_test.dart';
import 'package:twist_toast_example/main.dart';

void main() {
  testWidgets('TwistToast example app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TwistToastExampleApp());
    expect(find.text('TwistToast'), findsWidgets);
  });
}
