import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/pages/models/widgets/model_card.dart';
import 'package:inference/project.dart';

Project testProject() {
  return PublicProject(
    "test_id", "llm-model", "1.0.0", "TinyLlama", "2024-04-25T19:16:51.714000+00:00", ProjectType.text, "/dev/null", Image.asset("images/model_thumbnails/llama.jpg"), null
  )
  ..tasks.add(Task("task_id", "LLM", "LLM", [], null, [], "LLamaForCasualLM","int8"));
}

Widget modelWidget(Project project) {
  return FluentApp(
    home: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 240,
          maxHeight: 304,
        ),
        child: ModelCard(project: project)),
    )
  );
}

String? fromRichTextToPlainText(final Widget widget) {
  if (widget is RichText) {
    if (widget.text is TextSpan) {
      final buffer = StringBuffer();
      (widget.text as TextSpan).computeToPlainText(buffer);
      return buffer.toString();
    }
  }
  return null;
}



void main() {
  testWidgets("Test model card shows project info", (tester) async {
    final project = testProject();
    await tester.pumpWidget(modelWidget(project));

    expect(find.byWidgetPredicate((widget) => fromRichTextToPlainText(widget)?.contains(project.taskName()) ?? false), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => fromRichTextToPlainText(widget)?.contains(project.architecture) ?? false), findsOneWidget);
  });
}
