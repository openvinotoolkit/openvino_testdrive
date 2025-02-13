// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:inference/interop/llm_inference.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:langchain/langchain.dart';

class OpenVINOLLMOptions extends LLMOptions {
  /// {@macro fake_llm_options}
  const OpenVINOLLMOptions({this.temperature, this.applyTemplate, this.topP, super.model, super.concurrencyLimit});

  final bool? applyTemplate;
  final double? temperature;
  final double? topP;

  @override
  OpenVINOLLMOptions copyWith({
    final String? model,
    final bool? applyTemplate,
    final double? temperature,
    final double? topP,
    final int? concurrencyLimit,
  }) {
    return OpenVINOLLMOptions(
      model: model ?? this.model,
      applyTemplate: applyTemplate ?? this.applyTemplate,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      concurrencyLimit: concurrencyLimit ?? super.concurrencyLimit,
    );
  }

  @override
  OpenVINOLLMOptions merge(covariant final OpenVINOLLMOptions? other) {
    return copyWith(
      model: other?.model,
      temperature: other?.temperature,
      topP: other?.topP,
      concurrencyLimit: other?.concurrencyLimit,
    );
  }
}

class OpenVINOLLM extends SimpleLLM<OpenVINOLLMOptions> {

 LLMInference inference;

 OpenVINOLLM(this.inference, {required super.defaultOptions});

  @override
  String get modelType => 'custom';

 @override
  Future<String> callInternal(String prompt, {OpenVINOLLMOptions? options}) async {
    return (await promptLLM(prompt, options: options)).content;
  }

  Future<ModelResponse> promptLLM(String prompt, {OpenVINOLLMOptions? options}) {
    final opts = defaultOptions.merge(options);
    return inference.prompt(prompt, opts.applyTemplate ?? false, opts.temperature ?? 1.0, opts.topP ?? 1.0);
  }

  @override
  Future<List<int>> tokenize(final PromptValue promptValue, {final LLMOptions? options,}) async {
   throw UnimplementedError();
  }

  Stream<LLMResult> buildStream(PromptValue input, {OpenVINOLLMOptions? options}) async* {
    Completer<LLMResult> nextResponse = Completer<LLMResult>();
    bool done = false;
    int i = 0;
    inference.setListener((value) {
      nextResponse.complete(LLMResult(
        id: i.toString(),
        output: value,
        finishReason: FinishReason.unspecified,
        metadata: const {},
        usage: const LanguageModelUsage(),
      ));
      i++;
    });

    promptLLM(input.toString(), options: options).then((response) {
      done = true;
      nextResponse.complete(LLMResult(
        id: i.toString(),
        output: "",
        finishReason: FinishReason.stop,
        metadata: {
          "metrics": response.metrics
        },
        usage: const LanguageModelUsage(),
      ));
    });

    while (!done) {
      yield await nextResponse.future;
      nextResponse = Completer<LLMResult>();
    }
  }

  @override
  Stream<LLMResult> stream(PromptValue input, {OpenVINOLLMOptions? options}) {
    return buildStream(input, options: options);
  }
}
