/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:async';
import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/annotation.dart';
import 'package:inference/interop/openvino_bindings.dart' show SerializationOutput;
import 'package:inference/providers/image_inference_provider.dart';
import 'package:inference/widgets/canvas/canvas.dart';
import 'package:provider/provider.dart';

import 'dart:ui' as ui;

class CameraView extends StatefulWidget {
  final int deviceIndex;
  const CameraView({required this.deviceIndex, super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {

  late StreamController<ImageInferenceResult> streamController;
  late ImageInferenceProvider inferenceProvider;

  void onFrame(ImageInferenceResult result) {
    streamController.add(result);
  }

  void startCamera(){
    streamController = StreamController<ImageInferenceResult>();
    inferenceProvider.openCamera(widget.deviceIndex, onFrame, SerializationOutput(source: true, json: true));
  }

  @override
  void initState() {
    super.initState();
    inferenceProvider = Provider.of<ImageInferenceProvider>(context, listen: false);
    startCamera();
  }

  @override
  void dispose() {
    inferenceProvider.closeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ImageInferenceResult>(
      stream: streamController.stream,
      builder: (context, AsyncSnapshot<ImageInferenceResult> snapshot) {
        Future<ui.Image>? imageFuture = snapshot.data?.source != null ? decodeImageFromList(base64Decode(snapshot.data!.source!)) : null;
        return FutureBuilder(
          future: imageFuture,
          builder: (context, imageSnapshot) {
            if (imageSnapshot.data == null) {
              return Container();
            }
            return Canvas(
              image: imageSnapshot.data!,
              annotations: snapshot.data!.parseAnnotations(),
              labelDefinitions: inferenceProvider.project.labelDefinitions,
            );

          }
        );
      }
    );
  }
}
