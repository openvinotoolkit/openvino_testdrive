import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:inference/interop/generated_bindings.dart';
import 'package:inference/interop/tti_inference.dart';
import 'package:inference/project.dart';

enum Speaker { assistant, user }

class ImageContent {
  final Uint8List imageData;
  final int width;
  final int height;
  final BoxFit boxFit;
  const ImageContent(this.imageData, this.width, this.height, this.boxFit);

}

class Message {
  final Speaker speaker;
  final String message;
  final ImageContent? imageContent;
  final TTIMetrics? metrics;
  final bool allowedCopy; // Don't allow loading images to be copied

  const Message(this.speaker, this.message, this.imageContent, this.metrics, this.allowedCopy);
}

class TextToImageInferenceProvider extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  Project? get project => _project;

  String? get device => _device;

  TTIMetrics? get metrics => _messages.lastOrNull?.metrics;

  Uint8List? _imageBytes;

  int _loadWidth = 256;
  int _loadHeight = 256;

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
      preloadImageBytes();
      print("instantiating project: ${project.name}");
      print(project.storagePath);
      print(device);
    }
  }

  Future<void> init() async {
    await TTIInference.init(project!.storagePath, device!).then((instance) {
      print("done loading");
      _inference = instance;
    });
    loaded.complete();
    notifyListeners();
  }


  void preloadImageBytes() {
    rootBundle.load('images/intel-loading.gif').then((data) {
      _imageBytes = data.buffer.asUint8List();
      // Optionally notify listeners if you need to update UI
      notifyListeners();
    });
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
    final imageContent = ImageContent(_imageBytes ?? Uint8List(0), _loadWidth, _loadHeight, BoxFit.contain);

    return Message(Speaker.assistant, response!, imageContent, null, false);
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
    final response = await _inference!.prompt(message, width, height, rounds);

    final imageData  = base64Decode(response.content);
    final imageContent = ImageContent(imageData, _loadWidth, _loadHeight, BoxFit.contain);

    if (_messages.isNotEmpty) {
      _messages.add(Message(Speaker.assistant, "Generated image", imageContent, response.metrics, true));
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
