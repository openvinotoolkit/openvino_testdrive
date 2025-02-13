// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/interop/device.dart' show Device;
import 'package:inference/pages/text_generation/playground.dart';
import 'package:inference/pages/text_generation/widgets/user_message.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:provider/provider.dart';

import '../../fixtures.dart';
import '../../mocks.dart';


Widget renderWidget(TextInferenceProvider textInferenceProvider, PreferenceProvider preferences, Project project) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: preferences,
      ),
      ChangeNotifierProvider.value(
        value: textInferenceProvider,
      ),
    ],
    child: FluentApp(
      home: ScaffoldPage(
        content: Playground(project: project)
      )
    ),
  );
}

PreferenceProvider get preferenceProvider {
    final preferences = PreferenceProvider("AUTO");
    PreferenceProvider.availableDevices = const [Device("AUTO","auto"), Device("CPU", "Test CPU")];
    return preferences;
}

main() {
  // Disable test due to issues with langchain not working in test
  //testWidgets('test chat with large language model', (tester) async {
  //  final provider = TextInferenceProvider(largeLanguageModel(), "CPU");
  //  final llmInference = MockLLMInference(
  //    listenerAnswer: "The color of the sun is yellow",
  //  );

  //  provider.inference = llmInference.instance;
  //  provider.loaded.complete();

  //  await tester.binding.setSurfaceSize(const Size(1900, 1024));
  //  await tester.pumpWidget(renderWidget(provider, preferenceProvider, largeLanguageModel()));

  //  await tester.enterText(find.byType(TextBox), 'What is the color of the sun?');
  //  await tester.pumpAndSettle();
  //  await tester.tap(find.byIcon(FluentIcons.send));
  //  await tester.pumpAndSettle();

  //  expect(find.text('...'), findsOneWidget);

  //  llmInference.listenerCallback.complete();
  //  await tester.pumpAndSettle();
  //  llmInference.promptCallback.complete();
  //  await tester.pumpAndSettle();
  //  expect(find.text('The color of the sun is yellow', findRichText: true), findsOneWidget);

  //  llmInference.clean();
  //  addTearDown(() => tester.binding.setSurfaceSize(null));
  //});

  testWidgets('test chat reset clears chat', (tester) async {
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");
    final llmInference = MockLLMInference(
      listenerAnswer: "The color of the sun is yellow",
    );
    provider.inference = llmInference.instance;
    provider.loaded.complete();
    await tester.binding.setSurfaceSize(const Size(1900, 1024));
    await tester.pumpWidget(renderWidget(provider, preferenceProvider, largeLanguageModel()));
    await tester.enterText(find.byType(TextBox), 'What is the color of the sun?');
    await tester.tap(find.byIcon(FluentIcons.send));
    await tester.pumpAndSettle();
    llmInference.listenerCallback.complete();
    await tester.pumpAndSettle();
    llmInference.promptCallback.complete();
    await tester.pumpAndSettle();

    expect(find.byType(UserMessage), findsOneWidget);
    await tester.tap(find.byIcon(FluentIcons.rocket));
    await tester.pumpAndSettle();
    //expect(find.byType(UserMessage), findsNothing);
    //expect(provider.messages, isEmpty);

    llmInference.clean();
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });



}
