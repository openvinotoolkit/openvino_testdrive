import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/import/widgets/badge.dart';

void main() {
  testWidgets('Badge displays text and delete icon', (WidgetTester tester) async {
    const badgeText = 'Test Badge';
    bool deleteCalled = false;

    await tester.pumpWidget(
      FluentApp(
        home: ScaffoldPage(
          content: Badge(
            text: badgeText,
            onDelete: () {
              deleteCalled = true;
            },
          ),
        ),
      ),
    );

    // Verify the text is displayed
    expect(find.text(badgeText), findsOneWidget);

    // Verify the delete icon is displayed
    expect(find.byIcon(FluentIcons.clear), findsOneWidget);

    // Tap the delete icon and verify the callback is called
    await tester.tap(find.byIcon(FluentIcons.clear));
    expect(deleteCalled, isTrue);
  });
}
