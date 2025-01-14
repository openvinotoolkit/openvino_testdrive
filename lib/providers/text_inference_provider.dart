// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box_store.dart';
import 'package:inference/langchain/openvino_embeddings.dart';
import 'package:inference/langchain/openvino_llm.dart';
import 'package:inference/project.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
  const Message(this.speaker, this.message, this.metrics, this.time);
}

Future<Runnable> buildChain(LLMInference inference, KnowledgeGroup? group) async {
  final platformContext = Context(style: Style.platform);
  final directory = await getApplicationSupportDirectory();
  const device = "CPU";
  final embeddingsModelPath = platformContext.join(directory.path, "test", "all-MiniLM-L6-v2", "fp16");
  final embeddingsModel = await OpenVINOEmbeddings.init(embeddingsModelPath, device);

  if (group != null) {
    final vs = ObjectBoxStore(embeddings:  embeddingsModel, group: group);
    final model = OpenVINOLLM(inference, defaultOptions: const OpenVINOLLMOptions(temperature: 1, topP: 1, applyTemplate: false));


    final promptTemplate = ChatPromptTemplate.fromTemplate('''
<|system|>
Answer the question based only on the following context without specifically naming that it's from that context:
{context}

<|user|>
{question}
<|assistant|>
  ''');
    final retriever = vs.asRetriever();

    return Runnable.fromMap<String>({
      'context': retriever | Runnable.mapInput((docs) => docs.map((d) => d.pageContent).join('\n')),
      'question': Runnable.passthrough(),
    }) | promptTemplate | model | const StringOutputParser();
  } else {
    final model = OpenVINOLLM(inference, defaultOptions: const OpenVINOLLMOptions(temperature: 1, topP: 1, applyTemplate: true));
    final promptTemplate = ChatPromptTemplate.fromTemplate("{question}");

    return Runnable.fromMap<String>({
      'question': Runnable.passthrough(),
    }) | promptTemplate | model | const StringOutputParser();
  }
}

class TextInferenceProvider extends ChangeNotifier {

  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  Project? get project => _project;
  String? get device => _device;
  Metrics? get metrics => _messages.lastOrNull?.metrics;

  Future<Runnable>? chain;

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

  LLMInference? _inference;
  final stopWatch = Stopwatch();
  int n = 0;

  TextInferenceProvider(Project? project, String? device) {
    _project = project;
    _device = device;
  }

  Future<void> loadModel() async {
    if (project != null && device != null) {
      _inference = await LLMInference.init(project!.storagePath, device!);
      chain = buildChain(_inference!, knowledgeGroup);
      loaded.complete();
      notifyListeners();
    }
  }

  void onMessage(String word) {
     stopWatch.stop();
     if (n == 0) { // dont count first token since it's slow.
       stopWatch.reset();
     }

     double timeElapsed = stopWatch.elapsedMilliseconds.toDouble();
     double averageElapsed = (n == 0 ? 0.0 : timeElapsed / n);
     if (n == 0) {
       _response = word;
     } else {
       _response = _response! + word;
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
    if (_inference == null) {
      return "";
    }

    if (_inference?.chatEnabled == true) {
      return "Chat";
    } else {
      return "Text Generation";
    }
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

  Future<void> message(String message) async {

    _response = "...";
    _messages.add(Message(Speaker.user, message, null, DateTime.now()));
    notifyListeners();
    chain = buildChain(_inference!, knowledgeGroup);
    final runnable = (await chain)!;
    //final response = await _inference!.prompt(message, true, temperature, topP);

    String modelOutput = "";
    await for (final output in runnable.stream(message)) {
      final token = output.toString();
      modelOutput += token;
      onMessage(token);
    }
    print("end...");

    if (_messages.isNotEmpty) {
      _messages.add(Message(Speaker.assistant, modelOutput, null, DateTime.now()));
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
