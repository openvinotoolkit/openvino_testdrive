// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:provider/provider.dart';

Project testProject() {
  return PublicProject(
    "test_id", "llm-model", "1.0.0", "TinyLlama", "2024-04-25T19:16:51.714000+00:00", ProjectType.text, "/dev/null", Image.asset("images/model_thumbnails/llama.jpg"), null
  )
  ..tasks.add(Task("task_id", "LLM", "LLM", [], null, [], "LLamaForCasualLM","int8"));
}

Widget testWidget(ImageInferenceProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: provider,
      ),
    ],
    child: FluentApp(
      home: Center(
        child: ModelProperties(project: provider.project)
      ),
    ),
  );
}

void main() {
  testWidgets("Test model properties show model info", (tester) async {
    final model = testProject();
    final provider = ImageInferenceProvider(model, "CPU");
    await tester.pumpWidget(testWidget(provider));
    expect(find.text(model.name), findsOneWidget);
    expect(find.text(model.taskName()), findsOneWidget);
    expect(find.text(model.architecture), findsOneWidget);
  });
}
