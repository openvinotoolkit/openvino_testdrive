/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:async';
import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/interop/openvino_bindings.dart' show SerializationOutput;
import 'package:inference/providers/image_inference_provider.dart';
import 'package:provider/provider.dart';

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
    inferenceProvider.openCamera(widget.deviceIndex, onFrame, SerializationOutput(overlay: true));
  }

  @override
  void initState() {
    super.initState();
    inferenceProvider = Provider.of<ImageInferenceProvider>(context, listen: false);
    streamController = StreamController<ImageInferenceResult>();
    startCamera();
  }

  @override
  void dispose() {
    inferenceProvider.closeCamera();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceIndex != widget.deviceIndex) {
      inferenceProvider.closeCamera().then((_) => startCamera());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ImageInferenceResult>(
      stream: streamController.stream,
      builder: (context, AsyncSnapshot<ImageInferenceResult> snapshot) {
        final overlayData = snapshot.data?.overlay;
        final overlayImage = overlayData == null
          ? null
          : Image.memory(base64Decode(overlayData), gaplessPlayback: true,);


        return Builder(
          builder: (context) {
            if (overlayImage == null) {
              return Container();
            }
            return Center(child: overlayImage);
          }
        );
      }
    );
  }
}
