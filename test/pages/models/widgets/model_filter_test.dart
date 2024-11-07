import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:inference/pages/models/widgets/model_filter.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:provider/provider.dart';

Widget modelWidget(ProjectFilterProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const FluentApp(
      home: ModelFilter()
    )
  );
}

void main() {
  testWidgets("Test model filter can toggle groups", (tester) async {
    final provider= ProjectFilterProvider();
    await tester.pumpWidget(modelWidget(provider));

    final detectionFinder = find.text('Detection');
    final imageGroupFinder = find.text('Image');
    expect(detectionFinder, findsOneWidget);

    // Click toggle to hide computer vision models
    await tester.tap(imageGroupFinder);
    await tester.pump();
    expect(detectionFinder, findsNothing);

    // Click toggle to show computer vision models
    await tester.tap(imageGroupFinder);
    await tester.pump();

    expect(detectionFinder, findsOneWidget);
  });

  testWidgets("Test model sets task ", (tester) async {
    final provider= ProjectFilterProvider();
    await tester.pumpWidget(modelWidget(provider));

    final detectionFinder = find.text('Detection');
    expect(detectionFinder, findsOneWidget);

    expect(provider.option, null);
    await tester.tap(detectionFinder);
    expect(provider.option?.name, "Detection");
  });
}
