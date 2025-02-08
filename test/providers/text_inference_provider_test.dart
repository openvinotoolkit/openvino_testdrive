// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/providers/text_inference_provider.dart';

import 'package:mocktail/mocktail.dart';

import '../fixtures.dart';


class MockLLMInference extends Mock implements LLMInference {}

void main() {
  late MockLLMInference inference;

  setUpAll(() {
    inference = MockLLMInference();
  });

  test('test inference provider sets interim message ', () async {
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");

    final completer = Completer<void>();
    final metrics = calloc<Metrics>();
    when(() => inference.prompt(any(), any(), any())).thenAnswer((_) async {
      await completer.future;
      return ModelResponse("The color of the sun is yellow", metrics.ref);

    });
    provider.inference = inference;
    provider.message("What is the color of the sun?");
    expect(provider.interimResponse?.message, "...");
    calloc.free(metrics);
  });

  test('test inference provider sets messages with question and answer ', () async {
      print("Testing...");
    final provider = TextInferenceProvider(largeLanguageModel(), "CPU");

    final completer = Completer<void>();
    final metrics = calloc<Metrics>();
    when(() => inference.prompt(any(), any(), any())).thenAnswer((_) async {
      await completer.future;
      return ModelResponse("The color of the sun is yellow", metrics.ref);

    });
    provider.inference = inference;
    final request = provider.message("What is the color of the sun?");
    expect(provider.messages[0].message, "What is the color of the sun?");
    completer.complete();
    await request;
    expect(provider.interimResponse, null);
    expect(provider.messages[1].message, "The color of the sun is yellow");
    calloc.free(metrics);
  });
}
