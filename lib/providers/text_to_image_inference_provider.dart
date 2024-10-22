import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:inference/project.dart';
import 'package:image/image.dart' as img;

enum Speaker { assistant, user }

String speakerRole(Speaker speaker) {
  switch(speaker) {
    case Speaker.user:
      return "user";
    case Speaker.assistant:
      return "assistant";
  }
}

String speakerName(Speaker speaker) {
  switch(speaker) {
    case Speaker.user:
      return "You";
    case Speaker.assistant:
      return "Assistant";
  }
}

class Message {
  final Speaker speaker;
  final String message;
  final Image? image;
  final Metrics? metrics;
  const Message(this.speaker, this.message, this.image, this.metrics);
}

class TextToImageInferenceProvider extends ChangeNotifier {

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

  final stopWatch = Stopwatch();
  int n = 0;

  TextToImageInferenceProvider(Project? project, String? device) {
    _project = project;
    _device = device;

    if (project != null && device != null) {
      print("instantiating project: ${project.name}");
      print(project.storagePath);
      print(device);
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

  bool get initialized => true;
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
      return "Image Generation";

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
    _messages.add(Message(Speaker.user, message, null, null));
    notifyListeners();


    // final response = await _inference!.prompt(message, temperature, topP);

    final image = Image.asset('images/generated_image.jpg', width: 400);

    if (_messages.isNotEmpty) {
      _messages.add(Message(Speaker.assistant, "Generated image", image, null));
    }
    _response = null;
    n = 0;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void close() {
    _messages.clear();
    _response = null;
  }

  void forceStop() {
  }

  void reset() {
    //_inference?.close();
    _messages.clear();
    _response = null;
    notifyListeners();
  }


  @override
  void dispose() {
      close();
      super.dispose();
  }
}
