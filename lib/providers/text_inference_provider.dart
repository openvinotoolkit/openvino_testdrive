// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/langchain/all_mini_lm_v6.dart';
import 'package:inference/langchain/chain_builder.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box_store.dart';
import 'package:inference/langchain/openvino_embeddings.dart';
import 'package:inference/langchain/openvino_llm.dart';
import 'package:inference/pages/text_generation/utils/user_file.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:langchain/langchain.dart';

enum Speaker { system, assistant, user }

String speakerRole(Speaker speaker) {
  switch(speaker) {
    case Speaker.system:
      return "system";
    case Speaker.user:
      return "user";
    case Speaker.assistant:
      return "assistant";
  }
}

String speakerName(Speaker speaker) {
  switch(speaker) {
    case Speaker.system:
      return "Prompt";
    case Speaker.user:
      return "You";
    case Speaker.assistant:
      return "Assistant";
  }
}

class Message {
  final Speaker speaker;
  final String message;
  final Metrics? metrics;
  final DateTime? time;
  final List<String>? sources;
  const Message(this.speaker, this.message, this.metrics, this.time, {this.sources});
}

class TextInferenceProvider extends ChangeNotifier {

  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  Project? get project => _project;
  String? get device => _device;
  Metrics? get metrics => _messages.lastOrNull?.metrics;

  final memory = ConversationBufferMemory(returnMessages: true);

  final List<UserFile> _userFiles = [];

  Future<void> addUserFiles(List<UserFile> files ) async {
    if (files.isEmpty) return;
    _userFiles.addAll(files);
    final documents = files.expand((f) => f.documents).toList();
    await store!.addDocuments(documents: documents);
  }

  void removeUserFile(UserFile file ) {
    _userFiles.remove(file);
    final ids = file.documents.map((p) => p.id).whereType<String>().toList();
    store?.delete(ids: ids);
  }

  LLMInference? _inference;
  Embeddings? embeddingsModel;
  MemoryVectorStore? store;

  KnowledgeGroup? _knowledgeGroup;
  KnowledgeGroup? get knowledgeGroup => _knowledgeGroup;
  set knowledgeGroup(KnowledgeGroup? group) {
    _knowledgeGroup = group;
    notifyListeners();
  }

  double _temperature = 1;
  double get temperature => _temperature;
  set temperature(double v) {
    _temperature = v;
    notifyListeners();
  }

  double _topP = 1;
  double get topP => _topP;
  set topP(double v) {
    _topP = v;
    notifyListeners();
  }

  final stopWatch = Stopwatch();
  int n = 0;

  TextInferenceProvider(Project? project, String? device) {
    _project = project;
    _device = device;
  }

  Future<void> loadModel(DownloadProvider downloadProvider) async {
    if (project != null && device != null) {
      // Start downloading the embedings model if its missing
      final embeddingsModelLoader = AllMiniLMV6.ensureModelIsPresent(downloadProvider);
      // Load the inference model
      _inference = await LLMInference.init(project!.storagePath, device!);
      // Make sure the embeddings model is loaded.
      await embeddingsModelLoader;
      embeddingsModel = await OpenVINOEmbeddings.init(await AllMiniLMV6.storagePath, "CPU");
      store = MemoryVectorStore(embeddings: embeddingsModel!);
      loaded.complete();
      notifyListeners();
    }
  }

  void onToken(String word) {
     stopWatch.stop();
     if (n == 0) { // dont count first token since it's slow.
       stopWatch.reset();
     }

     double timeElapsed = stopWatch.elapsedMilliseconds.toDouble();
     double averageElapsed = (n == 0 ? 0.0 : timeElapsed / n);
     if (_response != null) {
      if (n == 0) {
        _response = word;
      } else {
        _response = _response! + word;
      }
     }
     _speed = averageElapsed;
     if (hasListeners) {
       notifyListeners();
     }
     stopWatch.start();
     n++;
  }

  bool sameProps(Project? project, String? device) {
    return _project == project && _device == device;
  }

  bool get initialized => loaded.isCompleted;
  final List<Message> _messages = [];

  double? _speed;
  double? get speed => _speed;
  set speed(double? speed) {
    _speed = speed;
    notifyListeners();
  }

  String? _response;
  String? get response => _response;
  set response(String? response) {
    _response = response;
    notifyListeners();
  }

  String get task {
    return project?.taskName() ?? "";
  }

  Message? get interimResponse {
    if (_response == null) {
      return null;
    }
    return Message(Speaker.assistant, response!, null, null);
  }

  List<Message> get messages {
    if (interimResponse == null) {
      return _messages;
    }
    return [..._messages, interimResponse!];
  }

  Future<void> message(String message, List<UserFile> files) async {
    _response = "...";
    _messages.add(Message(Speaker.user, message, null, DateTime.now(), sources: files.map((f) => f.path).toList()));
    notifyListeners();

    await addUserFiles(files);
    final List<VectorStore> stores = [];
    if (store != null && store!.memoryVectors.isNotEmpty) {
      stores.add(store!);
    }
    if (knowledgeGroup != null) {
      stores.add(ObjectBoxStore(embeddings: embeddingsModel!, group: knowledgeGroup!));
    }

    final chain = buildRAGChain(_inference!, embeddingsModel!, OpenVINOLLMOptions(temperature: temperature, topP: topP), stores, memory);
    final input = await chain.documentChain.invoke({"question": message}) as Map;
    final docs = input.containsKey("docs")
      ? List<String>.from(input["docs"].map((Document doc) => doc.metadata["source"]).toSet())
      : null;

    String modelOutput = "";
    Metrics? metrics;
    await for (final output in chain.answerChain.stream(input)) {
      final result = output as LLMResult;
      final token = result.output;
      if (result.metadata.containsKey("metrics")) {
        metrics = result.metadata["metrics"];
      }
      modelOutput += token;
      onToken(token);
    }

    memory.saveContext(
      inputValues: {'input': message},
      outputValues: {'output': modelOutput},
    );

    if (_messages.isNotEmpty) {
      _messages.add(Message(Speaker.assistant, modelOutput, metrics, DateTime.now(), sources: docs));
    }

    _response = null;
    n = 0;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void close() {
    _messages.clear();
    _inference?.close();
    _response = null;
    if (_inference != null) {
      _inference!.close();
    }
  }

  void forceStop() {
    _inference?.forceStop();
    if (_response != '...') {
      _messages.add(Message(Speaker.assistant, _response!, null, DateTime.now()));
    }
    _response = null;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void reset() {
    _inference?.forceStop();
    _inference?.clearHistory();
    memory.clear();
    for (final file in _userFiles) {
      final ids = file.documents.map((p) => p.id).whereType<String>().toList();
      store?.delete(ids: ids);
    }
    _messages.clear();
    _response = null;
    notifyListeners();
  }


  @override
  void dispose() {
    if (_inference != null) {
      _inference?.close();
      super.dispose();
    } else {
      close();
      super.dispose();
    }
  }
}
