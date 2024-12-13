import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/interop/device.dart';
import 'package:inference/pages/home/widgets/featured_card.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/widgets/device_selector.dart';
import 'package:provider/provider.dart';


Widget renderWidget(Model model) {


  return FluentApp(
        home: ScaffoldPage(
          content: FeaturedCard(
              model: model,
              onDownload: (m) {},
              onOpen: (m) {},
              downloaded: false),
        )
    );
}


void main() {
  var model = Model(name: 'Test model',
      id: 'test_model',
      fileSize: 1024,
      optimizationPrecision: 'int8',
      contextWindow: 0,
      description: 'A test model',
      task: 'speech'

  );


  testWidgets("Test featured model card", (tester) async {
    await tester.pumpWidget(renderWidget(model));
    await tester.pumpAndSettle();

    expect(find.text(model.name), findsOneWidget);
    expect(find.text("SPEECH\nTO\nTEXT"), findsOneWidget);
    expect(find.text(model.description), findsOneWidget);
  });

}