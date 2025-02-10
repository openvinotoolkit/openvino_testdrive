// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/interop/device.dart' show Device;
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/interop/openvino_bindings.dart' show ModelResponse, Metrics;
import 'package:inference/pages/text_generation/playground.dart';
import 'package:inference/pages/text_generation/widgets/user_message.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../../fixtures.dart';


class MockLLMInference extends Mock implements LLMInference {}

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
  late MockLLMInference inference;

  setUpAll(() {
    inference = MockLLMInference();
  });

  testWidgets('test chat with large language model', (tester) async {
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");
    provider.inference = inference;
    provider.loaded.complete();

    final completer = Completer<void>();

    final metrics = calloc<Metrics>();
    when(() => inference.prompt(any(), any(), any())).thenAnswer((_) async {
      await completer.future;
      return ModelResponse("The color of the sun is yellow", metrics.ref);

    });

    await tester.pumpWidget(renderWidget(provider, preferenceProvider, largeLanguageModel()));

    await tester.enterText(find.byType(TextBox), 'What is the color of the sun?');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(FluentIcons.send));
    await tester.pumpAndSettle();

    expect(find.text('...'), findsOneWidget);

    //inference.prompt gets a result.
    completer.complete();
    await tester.pumpAndSettle();
    expect(find.text('The color of the sun is yellow'), findsOneWidget);

    calloc.free(metrics);
  });

  testWidgets('test chat reset clears chat', (tester) async {
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");
    provider.inference = inference;
    provider.loaded.complete();
    final metrics = calloc<Metrics>();
    when(() => inference.prompt(any(), any(), any())).thenAnswer((_) async {
      return ModelResponse("The color of the sun is yellow", metrics.ref);
    });

    await tester.pumpWidget(renderWidget(provider, preferenceProvider, largeLanguageModel()));
    await tester.enterText(find.byType(TextBox), 'What is the color of the sun?');
    await tester.tap(find.byIcon(FluentIcons.send));
    await tester.pumpAndSettle();

    expect(find.byType(UserMessage), findsOneWidget);
    await tester.tap(find.byIcon(FluentIcons.rocket));
    await tester.pumpAndSettle();
    expect(find.byType(UserMessage), findsNothing);
    expect(provider.messages, isEmpty);

    calloc.free(metrics);
  });



}
