// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:math';

import 'package:inference/interop/llm_inference.dart';
import 'package:inference/langchain/jinja_prompt_template.dart';
import 'package:inference/langchain/openvino_llm.dart';
import 'package:langchain/langchain.dart';

String combineDocuments(
  final List<Document> documents, {
  final String separator = '\n\n',
}) =>
    documents.map((final d) => d.pageContent).join(separator);


RAGChain buildRAGChain(LLMInference llmInference, Embeddings embeddings, OpenVINOLLMOptions options, List<VectorStore> stores, BaseChatMemory memory) {
  final retrievers = combineStores(stores);

  final tokenizerConfig = jsonDecode(llmInference.getTokenizerConfig()) as Map<String, dynamic>;

  final retrievedDocs = Runnable.fromMap({
    'docs': Runnable.getItemFromMap('question') | retrievers,
    'question': Runnable.getItemFromMap('question'),
  });

  final promptTemplate = JinjaPromptTemplate.fromTemplateConfig(tokenizerConfig);

  final finalInputs = Runnable.fromMap({
    'context': Runnable.getItemFromMap<List<Document>>('docs') |
        Runnable.mapInput<List<Document>, String>(combineDocuments),
    'question': Runnable.getItemFromMap('question'),
    'history': Runnable.getItemFromMap('question') | Runnable.mapInput((_) async {
      final m = await memory.loadMemoryVariables();
      return m['history'];
    }),
  });
  final model = OpenVINOLLM(llmInference, defaultOptions: options.copyWith(applyTemplate: false));

  final answer = finalInputs | promptTemplate | model;

  return RAGChain(retrievedDocs, answer);
}

class RAGChain {
  final Runnable documentChain;
  final Runnable answerChain;

  const RAGChain(this.documentChain, this.answerChain);

}


Runnable<String, RunnableOptions, Object> combineStores(List<VectorStore> stores) {
  final Map<String, VectorStoreRetriever> retrievers = {};
  const maxDocumentsPerQuery = 4;

  for(final (index, store) in stores.indexed) {
    retrievers[index.toString()] = store.asRetriever();
  }

  return Runnable.fromMap(retrievers) | Runnable.mapInput((input) {
    final documents = List<Document>.from(input.values.expand((v) => v));
    return documents.sublist(0, min(documents.length, maxDocumentsPerQuery));
  });
}
