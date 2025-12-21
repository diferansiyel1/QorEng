import 'package:flutter_test/flutter_test.dart';

import 'package:engicore/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QorEngApp());

    // Verify that the app renders the Electrical screen initially.
    expect(find.text('Electrical'), findsWidgets);
  });
}
