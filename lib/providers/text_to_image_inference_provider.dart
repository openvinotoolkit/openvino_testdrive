import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:inference/interop/tti_inference.dart';
import 'package:inference/project.dart';

enum Speaker { assistant, user }

class Message {
  final Speaker speaker;
  final String message;
  final Image? image;
  final Metrics? metrics;
  final bool canCopy;

  const Message(this.speaker, this.message, this.image, this.metrics, this.canCopy);
}

class TextToImageInferenceProvider extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  Project? get project => _project;

  String? get device => _device;

  Metrics? get metrics => _messages.lastOrNull?.metrics;

  int _loadWidth = 512;
  int _loadHeight = 512;

  int _width = 512;

  int get width => _width;

  set width(int v) {
    _width = v;
    notifyListeners();
  }

  int _height = 512;

  int get height => _height;

  set height(int v) {
    _height = v;
    notifyListeners();
  }

  TTIInference? _inference;
  final stopWatch = Stopwatch();
  int n = 0;

  TextToImageInferenceProvider(Project? project, String? device) {
    _project = project;
    _device = device;

    if (project != null && device != null) {
      print("instantiating project: ${project.name}");
      print(project.storagePath);
      print(device);
      TTIInference.init(project.storagePath, device).then((instance) {
        print("done loading");
        _inference = instance;
        loaded.complete();
        notifyListeners();
      });
    }
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
    return "Image Generation";
  }

  Message? get interimResponse {
    if (_response == null) {
      return null;
    }
    final loadingImage = Image.asset('images/intel-loading.gif',
        width: _loadWidth.toDouble(), height: _loadHeight.toDouble(), fit: BoxFit.contain);

    return Message(Speaker.assistant, response!, loadingImage, null, false);
  }

  List<Message> get messages {
    if (interimResponse == null) {
      return _messages;
    }
    return [..._messages, interimResponse!];
  }

  Future<ui.Image> createImage(Uint8List bytes) async {
    return await decodeImageFromList(bytes);
  }

  Future<void> message(String message) async {
    _response = "Generating image...";

    _messages.add(Message(Speaker.user, message, null, null, false));
    notifyListeners();

    _loadWidth = width;
    _loadHeight = height;
    final response = await _inference!.prompt(message, width, height);

    final image = Image.memory(base64Decode(response.content), width: _loadWidth.toDouble(), height: _loadHeight.toDouble());

    if (_messages.isNotEmpty) {
      _messages.add(Message(Speaker.assistant, "Generated image", image, null, true));
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
    // Todo
  }

  void reset() {
    //_inference?.close();
    // _inference?.forceStop();
    // _inference?.clearHistory();
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
