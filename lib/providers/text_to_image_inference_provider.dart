// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart' show GenericMetrics;
import 'package:inference/interop/tti_inference.dart';
import 'package:inference/project.dart';

enum Speaker { assistant, system, user }

class ImageContent {
  final Uint8List imageData;
  final int width;
  final int height;
  final BoxFit boxFit;
  const ImageContent(this.imageData, this.width, this.height, this.boxFit);
}

class ImageMessage {
  final Speaker speaker;
  String message;
  final List<ImageContent> imageContent;
  final int rounds;
  Size size;
  GenericMetrics? metrics;
  DateTime? time;
  bool done = false; // Don't allow loading images to be copied

  ImageMessage(this.speaker, this.message, this.imageContent, this.rounds, this.size, this.metrics, this.time);

  void finalize(String message, [GenericMetrics? metrics]) {
    //imageContent.add(finalImage);
    time = DateTime.now();
    this.metrics = metrics;
    this.message = message;
    done = true;
  }
}

class TextToImageInferenceProvider extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  Project? get project => _project;

  String? get device => _device;

  GenericMetrics? get metrics => _messages.lastOrNull?.metrics;

  int _width = 256;

  int get width => _width;

  set width(int v) {
    _width = v;
    notifyListeners();
  }

  int _height = 256;

  int get height => _height;

  set height(int v) {
    _height = v;
    notifyListeners();
  }

  int _rounds = 12;

  int get rounds => _rounds;

  set rounds(int v) {
    _rounds = v;
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
    }
  }

  Future<void> init() async {
    await TTIInference.init(project!.storagePath, device!).then((instance) {
      print("done loading");
      _inference = instance;
      instance.setListener((response) {
          final imageData  = base64Decode(response.content);

          if (_response != null){
          final imageContent = ImageContent(imageData, _response!.size.width.toInt(), _response!.size.height.toInt(), BoxFit.contain);
            _response!.imageContent.add(imageContent);
            if (hasListeners){
              notifyListeners();
            }
          }
         //_intermediateImageStreamController.add(imageContent);
      });
    });
    loaded.complete();
    if (hasListeners) {
      notifyListeners();
    }
  }


  bool sameProps(Project? project, String? device) {
    return _project == project && _device == device;
  }

  bool get initialized => loaded.isCompleted;
  final List<ImageMessage> _messages = [];

  double? _speed;

  double? get speed => _speed;

  set speed(double? speed) {
    _speed = speed;
    notifyListeners();
  }

  ImageMessage? _response;

  ImageMessage? get interimResponse => _response;

  String get task {
    return "Image Generation";
  }

  List<ImageMessage> get messages {
    if (interimResponse == null) {
      return _messages;
    }
    return [..._messages, interimResponse!];
  }

  Future<ui.Image> createImage(Uint8List bytes) async {
    return await decodeImageFromList(bytes);
  }

  Future<void> message(String message) async {
    {
      _response = ImageMessage(Speaker.assistant, "Generating image...", [], rounds, Size(width.toDouble(), height.toDouble()), null, DateTime.now());
    }

    _messages.add(ImageMessage(Speaker.user, message, [], rounds, Size.zero, null, DateTime.now()));
    notifyListeners();

    try {
      final response = await _inference!.prompt(message, width, height, rounds);
      _messages.add(_response!..finalize("Generated image", response.metrics));
    } catch (e) {
      _messages.add(_response!..finalize("Interrupted"));
    }
    _response = null;

    n = 0;
    if (hasListeners) {
      notifyListeners();
    }
  }

  void close() async {
    await loaded.future;
    await forceStop();
    _messages.clear();
    _inference?.close();
    _response = null;
  }

  Future<void> forceStop() async {
    await _inference?.forceStop();
  }

  void reset() {
    _messages.clear();
    _response = null;
    notifyListeners();
  }

  @override
  void dispose() async {
    close();
    super.dispose();
  }
}
