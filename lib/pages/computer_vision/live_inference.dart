// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/annotation.dart';
import 'package:inference/interop/device.dart' show CameraDevice;
import 'package:inference/interop/openvino_bindings.dart' show SerializationOutput;
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/computer_vision/widgets/camera_view.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/device_selector.dart';
import 'package:inference/widgets/controls/drop_area.dart';
import 'package:inference/widgets/controls/no_outline_button.dart';
import 'package:inference/widgets/canvas/canvas.dart';
import 'package:provider/provider.dart';

import 'dart:ui' as ui;


enum LiveInferenceMode { camera, image }

class LiveInference extends StatefulWidget {
  final GetiProject project;

  const LiveInference({required this.project, super.key});

  @override
  State<LiveInference> createState() => _LiveInferenceState();
}

class _LiveInferenceState extends State<LiveInference> {
  Future<ImageInferenceResult>? inferenceResult;
  ui.Image? image;

  Future<List<CameraDevice>> cameraDevices = CameraDevice.getDevices();
  CameraDevice? cameraDevice;

  LiveInferenceMode mode = LiveInferenceMode.image;

  @override
  void initState() {
    super.initState();
  }

  void showUploadMenu(ImageInferenceProvider inferenceProvider) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      uploadFile(result.files.single.path!, inferenceProvider);
    }
  }

  void uploadFile(String path, ImageInferenceProvider inferenceProvider) async {
    if (mode == LiveInferenceMode.image) {
      inferenceProvider.closeCamera();
    }
    setState(() {
        mode = LiveInferenceMode.image;
        cameraDevice = null;
        image = null;
        inferenceResult = null;
    });

    Uint8List imageData = File(path).readAsBytesSync();
    final uiImage = await decodeImageFromList(imageData);
    setState(() {
        image = uiImage;
        inferenceResult = inferenceProvider.infer(imageData, SerializationOutput(json: true));
    });
  }

  void openCamera(CameraDevice camera) {
    setState(() {
        mode = LiveInferenceMode.camera;
        cameraDevice = camera;
    });
  }

  void closeCamera() {
    setState(() {
        mode = LiveInferenceMode.image;
        cameraDevice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Consumer<ImageInferenceProvider>(
      builder: (context, inferenceProvider, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 64,
                    child: GridContainer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            DropDownButton(
                              buttonBuilder: (context, callback) {
                                return NoOutlineButton(
                                  onPressed: callback,
                                  child: const Row(
                                    children: [
                                      Text("Choose image file"),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Icon(FluentIcons.chevron_down, size: 12),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              items: [
                                MenuFlyoutItem(text: const Text("Choose image file"), onPressed: () => showUploadMenu(inferenceProvider)),
                                //MenuFlyoutItem(text: const Text("Camera"), onPressed: () {}),
                                MenuFlyoutItem(text: const Text("Sample image"), onPressed: () {
                                  uploadFile(widget.project.samplePath(), inferenceProvider);
                                }),
                              ]
                            ),
                            FutureBuilder(
                              future: cameraDevices,
                              builder: (context, snapshot) {
                                List<CameraDevice> devices = snapshot.data ?? [];

                                return DropDownButton(
                                  buttonBuilder: (context, callback) {
                                    return NoOutlineButton(
                                      onPressed: callback,
                                      child: Row(
                                        children: [
                                          cameraDevice == null ? const Text("Choose camera") : Text("Choose camera: ${cameraDevice!.name}"),
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Icon(FluentIcons.chevron_down, size: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  items: [
                                    MenuFlyoutItem(text: const Text("None"), onPressed: () {
                                        closeCamera();
                                    }),

                                    for (final device in devices)
                                      MenuFlyoutItem(text: Text(device.name), onPressed: () => openCamera(device)),
                                  ]
                                );
                              }
                            ),
                            DeviceSelector(npuSupported: widget.project.npuSupported),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridContainer(
                      color: backgroundColor.of(theme),
                      child: FutureBuilder(
                        future: inferenceProvider.loaded.future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return switch(mode) {
                              LiveInferenceMode.camera => CameraView(device: cameraDevice!),
                              LiveInferenceMode.image => DropArea(
                                type: "image",
                                showChild: inferenceResult != null,
                                onUpload: (List<String> files) { uploadFile(files.first, inferenceProvider); },
                                extensions: const ["jpg", "jpeg", "bmp", "png", "tif", "tiff"],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FutureBuilder<ImageInferenceResult>(
                                    future: inferenceResult,
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData) {
                                        return Canvas(
                                          image: image!,
                                          annotations: snapshot.data!.parseAnnotations(),
                                          labelDefinitions: widget.project.labelDefinitions,
                                        );
                                      }
                                      return Center(child: Image.asset('images/intel-loading.gif', width: 100));
                                    }
                                  ),
                                ),
                              )
                          };
                        }
                        return Center(child: Image.asset('images/intel-loading.gif', width: 100));
                      }
                      ),
                    )
                  )
                ],
              ),
            ),
            ModelProperties(project: widget.project),
          ],
        );
      }
    );
  }
}
