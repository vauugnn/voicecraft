import 'package:flutter_test/flutter_test.dart';
import 'package:voicecraft/main.dart'; // Import your main.dart file

void main() {
  testWidgets('Test your widget functionality', (WidgetTester tester) async {
    // Build your app and trigger a frame.
    await tester.pumpWidget(MyApp()); // Remove `const` from here

    // Add your test logic here
    // For example, you can find widgets and interact with them
    // Example:
    // expect(find.text('Hello'), findsOneWidget); // Example test
  });
}
