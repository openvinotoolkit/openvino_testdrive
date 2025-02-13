// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:inference/providers/text_inference_provider.dart';

import 'package:mocktail/mocktail.dart';

import '../fixtures.dart';
import '../mocks.dart';


void main() {
  test('test inference provider sets interim message ', () async {
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");
    final llmInference = MockLLMInference();
    provider.inference = llmInference.instance;
    provider.message("What is the color of the sun?", []);
    expect(provider.interimResponse?.message, "...");
    llmInference.clean();
  });

  test('test inference provider sets messages with question and answer ', () async {
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");
    final llmInference = MockLLMInference(
      listenerAnswer: "The color of the sun is yellow",
    );

    provider.inference = llmInference.instance;
    final request = provider.message("What is the color of the sun?", []);
    expect(provider.messages[0].message, "What is the color of the sun?");
    llmInference.listenerCallback.complete();
    await Future.delayed(Duration.zero);
    llmInference.promptCallback.complete();
    await request;
    expect(provider.interimResponse, null);
    expect(provider.messages[1].message, "The color of the sun is yellow");
    llmInference.clean();
  });

  test('test inference provider dispose triggers close ', () async {
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");
    final llmInference = MockLLMInference();
    provider.inference = llmInference.instance;
    provider.dispose();
    verify(llmInference.instance.close).called(1);
  });
}
