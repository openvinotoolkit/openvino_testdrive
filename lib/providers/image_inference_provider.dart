// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:inference/utils/image_graph_builder.dart';
import 'package:inference/interop/graph_runner.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/project.dart';


class ImageInferenceProvider extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();
  final Project project;
  final String device;
  GraphRunner? _inference;
  GraphRunner? get inference => _inference;

  ImageInferenceProvider(this.project, this.device);

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

  Future<void> init() async {
    final graph = await ImageGraphBuilder(project, device).buildGraph();
    _inference = await GraphRunner.init(graph);
    loaded.complete();
    notifyListeners();
  }

  bool sameProps(Project project, String device) {
    return this.project == project && this.device == device;
  }

  Future<ImageInferenceResult> infer(Uint8List file, SerializationOutput output) async {
    int timestamp = inference!.getTimestamp() + 1;
    _inference!.queueImage("input", timestamp, file);
    _inference!.queueSerializationOutput("serialization_output", timestamp, output);
    final result = await _inference!.get();
    return ImageInferenceResult.fromJson(jsonDecode(result));
  }

  @override
  void dispose() {
    _inference?.close();
    super.dispose();
  }

  void openCamera(int deviceIndex, Function(ImageInferenceResult) callback, SerializationOutput output) {
    _inference!.startCamera(deviceIndex, (String output) => callback(ImageInferenceResult.fromJson(jsonDecode(output))), output);
  }

  void closeCamera() {
    _inference?.stopCamera();
  }

  void setListener(Function(ImageInferenceResult) fn) {
    // TODO(RHeckerIntel): Implemnet for graph runner
  }
}
