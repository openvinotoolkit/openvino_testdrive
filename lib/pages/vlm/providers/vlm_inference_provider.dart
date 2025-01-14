// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:inference/interop/vlm_inference.dart';
import 'package:inference/project.dart';

enum Speaker { assistant, user }


class Message {
  final Speaker speaker;
  final String message;
  final VLMMetrics? metrics;
  final bool allowedCopy; // Don't allow loading images to be copied

  const Message(this.speaker, this.message, this.metrics, this.allowedCopy);
}

class VLMInferenceProvider extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  Project? get project => _project;

  String? get device => _device;

  VLMMetrics? get metrics => _messages.lastOrNull?.metrics;

  int _maxTokens = 100;

  int get maxTokens => _maxTokens;

  set maxTokens(int v) {
    _maxTokens = v;
    notifyListeners();
  }

  VLMInference? _inference;
  final stopWatch = Stopwatch();
  int n = 0;

  VLMInferenceProvider(Project? project, String? device) {
    _project = project;
    _device = device;

    if (project != null && device != null) {
      print("instantiating project: ${project.name}");
      print(project.storagePath);
      print(device);
    }
  }

  Future<void> init() async {

    _inference = await VLMInference.init(project!.storagePath, device!)
      ..setListener(onMessage);

    loaded.complete();
    if (hasListeners) {
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
    return "Image Generation";
  }

  Message? get interimResponse {
    if (_response == null) {
      return null;
    }

    return Message(Speaker.assistant, response!, null, false);
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
    _response = "...";

    _messages.add(Message(Speaker.user, message, null, false));
    notifyListeners();

    final response = await _inference!.prompt(message, maxTokens);

    if (_messages.isNotEmpty) {
      _messages.add(Message(Speaker.assistant, response.content, response.metrics, true));
    }
    _response = null;

    n = 0;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void setImagePaths(List<String> paths) {
    _inference?.setImagePaths(paths);
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
      _messages.add(Message(Speaker.assistant, _response!, null, true));
    }
    _response = null;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void reset() {
    //_inference?.close();
    _inference?.forceStop();
    // _inference?.clearHistory();
    _messages.clear();
    _response = null;
    notifyListeners();
  }


  Future<void> _closeInferenceInIsolate(dynamic inference) async {
    final receivePort = ReceivePort();

    // Spawn an isolate and pass the SendPort and inference
    await Isolate.spawn((List<dynamic> args) {
      final SendPort sendPort = args[0];
      final dynamic inference = args[1];
      try {
        inference?.close(); // Perform the blocking operation
      } catch (e) {
        print("Error closing inference: $e");
      } finally {
        sendPort.send(null); // Notify that the operation is complete
      }
    }, [receivePort.sendPort, inference]);

    // Wait for the isolate to complete
    await receivePort.first;
  }

  Future<void> _waitForLoadCompletion() async {
    if (!loaded.isCompleted) {
      print("Still loading model, await disposal");
      await loaded.future;
    }
  }

  @override
  void dispose() async {
    // Wait for model to finish loading
    await _waitForLoadCompletion();

    if (_inference != null) {
      print("Closing inference");
      await _closeInferenceInIsolate(_inference!);
      print("Closing inference done");
    } else {
      close();
    }

    super.dispose(); // Always call super.dispose()
  }
}