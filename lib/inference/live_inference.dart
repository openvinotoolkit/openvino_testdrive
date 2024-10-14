import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inference/inference/camera_page.dart';
import 'package:inference/canvas/canvas.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:inference/utils/drop_area.dart';
import 'package:provider/provider.dart';


Future<ui.Image> createImage(Uint8List bytes) async {
  return await decodeImageFromList(bytes);
}

class LiveInference extends StatefulWidget {
  final Project project;
  const LiveInference(this.project, {super.key});

  @override
  State<LiveInference> createState() => _LiveInferenceState();
}

enum MenuButtons { camera, sample, upload }

class _LiveInferenceState extends State<LiveInference> {

  bool loading = false;
  bool cameraMode = false;
  ImageInferenceResult? inferenceResult;
  ui.Image? image;

  void showUploadMenu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      uploadFile(result.files.single.path!);
    }
  }

  void uploadFile(String path) async {
    Uint8List imageData = File(path).readAsBytesSync();
    setState(() {
        inferenceResult = null;
        loading = true;
    });

    final inferenceProvider = Provider.of<ImageInferenceProvider>(context, listen: false);

    inferenceProvider.loaded.future.then((_) async{
      final output = await inferenceProvider.infer(imageData, SerializationOutput(json: true));
      final uiImage = await decodeImageFromList(imageData);
      setState(() {
          loading = false;
          inferenceResult = output;
          image = uiImage;
      });
    });

  }

  void handleMenu(MenuButtons option) {
    switch(option) {
      case MenuButtons.camera:
        setState(() {
            cameraMode = true;
        });
        break;
      case MenuButtons.sample:
        uploadFile(widget.project.samplePath());
        break;
      case MenuButtons.upload:
        showUploadMenu();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageInferenceProvider>(
      builder: (context, inference, child) {
        final isLoading = loading || inference.inference == null;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DeviceSelector(),
                  PopupMenuButton(
                    onSelected: (val) => handleMenu(val),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: textColor),
                          borderRadius: BorderRadius.circular(4.0),
                          color: intelGrayReallyDark,
                          //color: intelGrayLight,
                        ),
                        width: 168,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Upload image"),
                              const Icon(
                                Icons.expand_more,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                    elevation: 0,
                    offset: const Offset(0, 35),
                    shape: RoundedRectangleBorder (
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(
                        color: textColor,
                        width: 1,
                      )
                    ),
                    color: intelGrayReallyDark,
                    itemBuilder: (BuildContext context) {
                      if (widget.project.hasSample) {
                        return <PopupMenuEntry<MenuButtons>>[
                          const PopupMenuItem<MenuButtons>(
                            height: 20,
                            value: MenuButtons.sample,
                            child: MenuButton('Sample image'),
                          ),
                          const PopupMenuItem<MenuButtons>(
                            height: 20,
                            value: MenuButtons.upload,
                            child: MenuButton('Choose an image file'),
                          ),
                          //const PopupMenuItem<MenuButtons>(
                          //  height: 20,
                          //  value: MenuButtons.camera,
                          //  child: MenuButton('Camera'),
                          //),
                        ];
                      }
                      return <PopupMenuEntry<MenuButtons>>[
                        const PopupMenuItem<MenuButtons>(
                          height: 20,
                          value: MenuButtons.upload,
                          child: MenuButton('Choose an image file'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            (isLoading
              ? Expanded(
                child: Center(
                  child: Image.asset('images/intel-loading.gif', width: 100)
                )
              )
              : Builder(
                builder: (context) {
                  if (cameraMode) {
                    return CameraPage(inference);
                  }
                  return DropArea(
                      type: "image",
                      extensions: const ["jpg, jpeg, bmp, png, tif, tiff"],
                      onUpload: (String path) => uploadFile(path),
                      showChild: inferenceResult != null,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Builder(
                            builder: (context) {
                              if (inferenceResult == null) {
                                return Container();
                              }
                              return Canvas(
                                image: image!,
                                annotations: inferenceResult!.parseAnnotations(),
                                labelDefinitions: widget.project.labelDefinitions,
                              );
                            }
                          )
                      )
                    );
                }
              )
            )
          ],
        );
      }
    );
  }
}

class MenuButton extends StatelessWidget {
  final String name;
  const MenuButton(this.name, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(name,
        style: const TextStyle(
          fontSize: 10,
        ),
      ),
    );

  }
}

