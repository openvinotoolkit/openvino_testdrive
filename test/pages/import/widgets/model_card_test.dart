import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/pages/import/widgets/model_card.dart';

void main() {
  testWidgets('ModelCard displays model information correctly', (WidgetTester tester) async {
    final model = Model(
      name: 'Test Model',
      id: 'test_model',
      fileSize: 1024,
      optimizationPrecision: 'FP16',
      contextWindow: 512,
      description: 'This is a test model description.',
      task: 'classification',
    );

    await tester.pumpWidget(
      FluentApp(
        home: ScaffoldPage(
          content: ModelCard(
            model: model,
            checked: false,
            onChecked: (bool value) {},
          ),
        ),
      ),
    );

    expect(find.text('Test Model'), findsOneWidget);
    expect(find.text('This is a test model description.'), findsOneWidget);
    expect(find.text('Optimization: FP16', findRichText: true), findsOneWidget);
    expect(find.text('Size: 1 kB', findRichText: true), findsOneWidget);
    expect(find.text('classification'), findsOneWidget);
  });

  testWidgets('ModelCard calls onChecked when tapped', (WidgetTester tester) async {
    final model = Model(
      name: 'Test Model',
      id: 'test_model',
      fileSize: 1024,
      optimizationPrecision: 'FP16',
      contextWindow: 512,
      description: 'This is a test model description.',
      task: 'classification',
    );

    bool checked = false;

    await tester.pumpWidget(
      FluentApp(
        home: ScaffoldPage(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return ModelCard(
                model: model,
                checked: checked,
                onChecked: (bool value) {
                  setState(() {
                    checked = value;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Tap the ModelCard
    await tester.tap(find.byType(ModelCard));
    await tester.pumpAndSettle();

    // Verify that the checked variable has been updated
    expect(checked, isTrue);

    // Tap the ModelCard
    await tester.tap(find.byType(ModelCard));
    await tester.pumpAndSettle();

    // Verify that the checked variable has been updated
    expect(checked, isFalse);
  });
}
