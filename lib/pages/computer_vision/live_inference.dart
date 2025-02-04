// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
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

class LiveInference extends StatefulWidget {
  final Project project;

  const LiveInference({required this.project, super.key});

  @override
  State<LiveInference> createState() => _LiveInferenceState();
}

class _LiveInferenceState extends State<LiveInference> {
  Future<ImageInferenceResult>? inferenceResult;
  ui.Image? image;

  void showUploadMenu() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      uploadFile(result.files.single.path!);
    }
  }

  void uploadFile(String path) async {
    setState(() {
      image = null;
      inferenceResult = null;
    });

    Uint8List imageData = File(path).readAsBytesSync();
    final inferenceProvider =
        Provider.of<ImageInferenceProvider>(context, listen: false);
    final uiImage = await decodeImageFromList(imageData);
    setState(() {
      image = uiImage;
      inferenceResult =
          inferenceProvider.infer(imageData, SerializationOutput(json: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

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
                                      child: Icon(FluentIcons.chevron_down,
                                          size: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                            items: [
                              MenuFlyoutItem(
                                  text: const Text("Choose image file"),
                                  onPressed: showUploadMenu),
                              //MenuFlyoutItem(text: const Text("Camera"), onPressed: () {}),
                              MenuFlyoutItem(
                                  text: const Text("Sample image"),
                                  onPressed: () {
                                    uploadFile(widget.project.samplePath());
                                  }),
                            ]),
                        const DeviceSelector(),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridContainer(
                  color: backgroundColor.of(theme),
                  child: Builder(builder: (context) {
                    return DropArea(
                      type: "image",
                      showChild: inferenceResult != null,
                      onUpload: (String file) {
                        uploadFile(file);
                      },
                      extensions: const [
                        "jpg",
                        "jpeg",
                        "bmp",
                        "png",
                        "tif",
                        "tiff"
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<ImageInferenceResult>(
                            future: inferenceResult,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Canvas(
                                  image: image!,
                                  annotations:
                                      snapshot.data!.parseAnnotations(),
                                  labelDefinitions:
                                      widget.project.labelDefinitions,
                                );
                              }
                              return Center(
                                  child: Image.asset('images/intel-loading.gif',
                                      width: 100));
                            }),
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
        ModelProperties(project: widget.project),
      ],
    );
  }
}
