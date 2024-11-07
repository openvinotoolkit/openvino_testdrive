import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/pages/models/widgets/model_card.dart';
import 'package:inference/pages/models/widgets/model_list.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:provider/provider.dart';

Project testProject(String name) {
  return PublicProject(
    "test_id", "llm-model", "1.0.0", name, "2024-04-25T19:16:51.714000+00:00", ProjectType.text, "/dev/null", Image.asset("images/model_thumbnails/llama.jpg"), null
  )
  ..tasks.add(Task("task_id", "LLM", "LLM", [], null, [], "LLamaForCasualLM","int8"));
}

Widget renderWidget(ProjectProvider provider, ProjectFilterProvider filterProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: provider,
      ),
      ChangeNotifierProvider.value(
        value: filterProvider,
      ),
    ],
    child: FluentApp(
      home: const ScaffoldPage(
        content: ModelList()
      )
    ),
  );
}

void main() {
  testWidgets("Test only models that match filter are shown", (tester) async {
    final tinyLlamaModel = testProject("TinyLlama");
    final instructModel = testProject("Instruct");
    final projectProvider = ProjectProvider([tinyLlamaModel, instructModel]);
    final filterProvider = ProjectFilterProvider();
    await tester.pumpWidget(renderWidget(projectProvider, filterProvider));

    final searchbar = find.byType(TextBox);
    await tester.enterText(searchbar, "tinyllama");
    await tester.pumpAndSettle();

    expect(find.text(tinyLlamaModel.name), findsOneWidget);
    expect(find.text(instructModel.name), findsNothing);

  });

  testWidgets("Test models are shown in order of name", (tester) async {
    final tinyLlamaModel = testProject("TinyLlama");
    final instructModel = testProject("Instruct");
    final projectProvider = ProjectProvider([tinyLlamaModel, instructModel]);
    final filterProvider = ProjectFilterProvider();
    await tester.pumpWidget(renderWidget(projectProvider, filterProvider));

    final expected = [instructModel.name, tinyLlamaModel.name];
    final titleWidgets = find.descendant(of: find.byType(ModelCard), matching: find.byType(Text)).evaluate();
    {
      final titles = titleWidgets.map((title) => (title.widget as Text).data).toList();
      expect(titles, expected);
    }

    await tester.tap(find.byWidgetPredicate((widget) => widget is Icon && widget.icon == FluentIcons.sort));

    await tester.pumpAndSettle();

    {
      final titles = titleWidgets.map((title) => (title.widget as Text).data).toList();
      expect(titles, expected.reversed);
    }
  });
}
