import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:inference/image_graph_builder.dart';
import 'package:inference/interop/graph_runner.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/project.dart';


class ImageInferenceProvider extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();
  final Project project;
  final String device;
  int timestamp = 0;
  GraphRunner? _inference;
  GraphRunner? get inference => _inference;

  ImageInferenceProvider(this.project, this.device) {
    ImageGraphBuilder(project, device).buildGraph().then((graph) {
      init(graph);
    });
  }

  bool _locked = false;

  void lock() {
    _locked = true;
    notifyListeners();
  }

  void unlock() {
    _locked = false;
    notifyListeners();
  }

  bool get isLocked => _locked;

  bool get isReady => _inference != null;

  Future<void> init(String graph) async {
    _inference = await GraphRunner.init(graph);
    loaded.complete();
    notifyListeners();
  }

  Future<ImageInferenceResult> infer(Uint8List file, SerializationOutput output) async {
    _inference!.queueImage("input", timestamp, file);
    _inference!.queueSerializationOutput("serialization_output", timestamp, output);
    timestamp += 1;
    final result = await _inference!.get();
    return ImageInferenceResult.fromJson(jsonDecode(result));
  }

  @override
  void dispose() {
    if (_inference != null) {
      _inference?.close();
    }
    super.dispose();
  }

  void openCamera(int id) {
    // TODO: Implemnet for graph runner
  }

  void closeCamera() {
    // TODO: Implemnet for graph runner
  }

  void setListener(Function(ImageInferenceResult) fn) {
    // TODO: Implemnet for graph runner
  }



}
