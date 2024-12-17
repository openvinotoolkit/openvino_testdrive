// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/project.dart';

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

class TextInferenceProvider extends ChangeNotifier {

  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  Project? get project => _project;
  String? get device => _device;
  Metrics? get metrics => _messages.lastOrNull?.metrics;

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
      _inference = await LLMInference.init(project!.storagePath, device!)
        ..setListener(onMessage);
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
    final response = await _inference!.prompt(message, temperature, topP);

    if (_messages.isNotEmpty) {
      _messages.add(Message(Speaker.assistant, response.content, response.metrics, DateTime.now()));
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
    //_inference?.close();
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
