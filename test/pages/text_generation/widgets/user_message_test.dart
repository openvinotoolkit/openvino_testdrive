import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/pages/text_generation/widgets/user_message.dart';

void main() {
  testWidgets('UserMessage renders text correctly', (WidgetTester tester) async {
    // Create a sample message
    const message = Message(Speaker.user, 'Hello, this is a test message!', null, null);

    // Build the UserMessage widget
    await tester.pumpWidget(
      const FluentApp(
        home: UserMessage(message),
      ),
    );

    // Verify if the text is rendered correctly
    expect(find.text('Hello, this is a test message!'), findsOneWidget);
  });
}