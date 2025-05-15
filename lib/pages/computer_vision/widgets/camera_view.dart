/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:async';
import 'dart:convert';

import 'package:inference/pages/computer_vision/widgets/automation_options.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/annotation.dart';
import 'package:inference/interop/device.dart';
import 'package:inference/interop/openvino_bindings.dart' show SerializationOutput;
import 'package:inference/providers/image_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/canvas/canvas.dart';
import 'package:inference/widgets/controls/no_outline_button.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:provider/provider.dart';

import 'dart:ui' as ui;


class SmoothFPSCounter {
  late final StreamController<double> _fpsStreamController;
  late final Stream<double> fpsStream;

  int counter = 0;
  late DateTime start;

  SmoothFPSCounter(Stream<ImageInferenceResult> stream){
    _fpsStreamController = StreamController<double>();
    fpsStream = _fpsStreamController.stream.asBroadcastStream();
    reset();

    stream.listen((_) {
        counter += 1;
    });
    stream.throttleTime(Duration(seconds: 1)).listen((p) {
       final fps = counter.toDouble() / DateTime.now().difference(start).inMilliseconds * 1000.0;
       _fpsStreamController.add(fps);
    });
  }

  void reset() {
    counter = 0;
    start = DateTime.now();
  }
}

class CameraView extends StatefulWidget {
  final CameraDevice device;
  const CameraView({required this.device, super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {

  late StreamController<ImageInferenceResult> streamController;
  late final Stream<ImageInferenceResult> stream;
  late ImageInferenceProvider inferenceProvider;
  late SmoothFPSCounter fpsCounter;

  void onFrame(ImageInferenceResult result) {
    streamController.add(result);
  }

  void startCamera(){
    inferenceProvider.openCamera(widget.device.id, onFrame, SerializationOutput(source: true, json: true));
  }

  @override
  void initState() {
    super.initState();
    streamController = StreamController<ImageInferenceResult>();
    stream = streamController.stream.asBroadcastStream();
    fpsCounter = SmoothFPSCounter(stream);
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
    final theme = FluentTheme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 64,
          child: GridContainer(
            color: neutralBackground.of(theme),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CameraOptions(
                  fpsStream: fpsCounter.fpsStream,
                  device: widget.device,
                  inferenceProvider: inferenceProvider,
                  onResolutionChange: (_) {
                    fpsCounter.reset();
                  },
                ),
                AutomationOptions(
                  stream: stream
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<ImageInferenceResult>(
            stream: stream,
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
          ),
        ),
      ],
    );
  }
}



class CameraOptions extends StatefulWidget {
  final CameraDevice device;
  final ImageInferenceProvider inferenceProvider;
  final Stream<double> fpsStream;
  final Function(Resolution resolution)? onResolutionChange;

  const CameraOptions({
      required this.device,
      required this.inferenceProvider,
      required this.fpsStream,
      this.onResolutionChange,
      super.key});

  @override
  State<CameraOptions> createState() => _CameraOptionsState();
}

class _CameraOptionsState extends State<CameraOptions> {

  Resolution? resolution;

  @override
  void initState() {
    super.initState();
    resolution = widget.device.resolutions.firstOrNull;
  }

  void setResolution(Resolution res, ImageInferenceProvider inferenceProvider) {
    setState(() {
        inferenceProvider.setCameraResolution(res);
        resolution = res;
        widget.onResolutionChange?.call(res);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fpsFormatter = NumberFormat.decimalPatternDigits(decimalDigits: 2);
    return Row(
      children: [
        StreamBuilder<double>(
          stream: widget.fpsStream,
          builder: (context, snapshot) {
            final fps  = snapshot.data ?? 0;
            return Text("FPS: ${fpsFormatter.format(fps)}");
          }
        ),
        Builder(
          builder: (context) {
            if (widget.device.resolutions.isEmpty) {
              return Container();
            }
            return DropDownButton(
              buttonBuilder: (context, callback) {
                return NoOutlineButton(
                  onPressed: callback,
                  child: Row(
                    children: [
                      Text("Resolution: ${resolution!.width} x ${resolution!.height}"),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(FluentIcons.chevron_down, size: 12),
                      ),
                    ],
                  ),
                );
              },
              items: [
                for (final resolution in widget.device.resolutions)
                  MenuFlyoutItem(text: Text("${resolution.width} x ${resolution.height}"), onPressed: () => setResolution(resolution, widget.inferenceProvider)),
              ]
            );
          }
        ),
      ],
    );
  }
}
