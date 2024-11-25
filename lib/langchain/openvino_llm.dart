import 'dart:async';

import 'package:inference/interop/llm_inference.dart';
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
    final opts = defaultOptions.merge(options);
    return (await inference.prompt(prompt, opts.applyTemplate ?? true, opts.temperature ?? 1.0, opts.topP ?? 1.0)).content;
  }

  @override
  Future<List<int>> tokenize(final PromptValue promptValue, {final LLMOptions? options,}) async {
   throw UnimplementedError();
  }
}
