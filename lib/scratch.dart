import 'dart:async';

import 'package:inference/interop/llm_inference.dart';
import 'package:langchain/langchain.dart';

class OpenVINOLLMOptions extends LLMOptions {
  /// {@macro fake_llm_options}
  const OpenVINOLLMOptions({this.temperature, this.topP, super.model, super.concurrencyLimit});

  final double? temperature;
  final double? topP;

  @override
  OpenVINOLLMOptions copyWith({
    final String? model,
    final double? temperature,
    final double? topP,
    final int? concurrencyLimit,
  }) {
    return OpenVINOLLMOptions(
      model: model ?? this.model,
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

 final String modelPath;
 final Completer<void> completer = Completer();
 LLMInference? _inference;

 LLMInference get inference => _inference!;

 OpenVINOLLM(this.modelPath, {required super.defaultOptions}) {
   LLMInference.init(modelPath, "CPU").then((instance) {
       _inference = instance;
       completer.complete();
   });
 }

  @override
  String get modelType => 'custom';

 @override
  Future<String> callInternal(String prompt, {OpenVINOLLMOptions? options}) async {
    await completer.future;
    final opts = defaultOptions.merge(options);
    return (await inference.prompt(prompt, opts.temperature ?? 1.0, opts.topP ?? 1.0)).content;
  }

  @override
  Future<List<int>> tokenize(final PromptValue promptValue, {final LLMOptions? options,}) async {
   throw UnimplementedError();
  }
}

void testOvLangChain() async {
  const modelPath = "/data/genai/TinyLlama-1.1B-Chat-v1.0-int4-ov";

  final promptTemplate = PromptTemplate.fromTemplate(
    'tell me a joke about {subject}',
  );
  final model = OpenVINOLLM(modelPath, defaultOptions: const OpenVINOLLMOptions(temperature: 1, topP: 0.5));
  final chain = promptTemplate.pipe(model).pipe(const StringOutputParser());
  final result = await chain.invoke({'subject': 'AI'});
  print(result);
}

int main(){
  print("scratch");

  testOvLangChain();

  return 0;
}
