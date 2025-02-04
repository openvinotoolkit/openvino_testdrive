import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
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

class StreamInference extends StatefulWidget {
  final Project project;

  const StreamInference({required this.project, super.key});

  @override
  State<StreamInference> createState() => _StreamInferenceState();
}

class _StreamInferenceState extends State<StreamInference> {
  CameraController? _cameraController;
  CameraDescription? selectedCamera;
  List<CameraDescription> availableCamerasList = [];

  @override
  void initState() {
    super.initState();
    loadAvailableCameras();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<ImageInferenceResult>? inferenceResult;
  ui.Image? processedImage;

  // void showUploadMenu() async {
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(type: FileType.image);

  //   if (result != null) {
  //     uploadFile(result.files.single.path!);
  //   }
  // }

  // void uploadFile(String path) async {
  //   setState(() {
  //     processedImage = null;
  //     inferenceResult = null;
  //   });

  //   Uint8List imageData = File(path).readAsBytesSync();
  //   final inferenceProvider =
  //       Provider.of<ImageInferenceProvider>(context, listen: false);
  //   final uiImage = await decodeImageFromList(imageData);
  //   setState(() {
  //     processedImage = uiImage;
  //     inferenceResult =
  //         inferenceProvider.infer(imageData, SerializationOutput(json: true));
  //   });
  // }

  // Load all available cameras
  void loadAvailableCameras() async {
    debugPrint("Loading available cameras...");
    final cameras = await availableCameras();
    setState(() {
      availableCamerasList = cameras;
    });
    debugPrint(
        "Available cameras loaded: ${availableCamerasList.map((e) => e.name).toList()}");
  }

  bool isCameraInitializing = false;

  void openCamera() async {
    if (selectedCamera == null || isCameraInitializing) return;

    isCameraInitializing = true;

    // Dispose of any existing camera instance before initializing a new one
    if (_cameraController != null) {
      await _cameraController?.dispose();
      _cameraController = null;
    }

    // Initialize the selected camera
    _cameraController = CameraController(
      selectedCamera!,
      ResolutionPreset.high,
    );

    try {
      await _cameraController?.initialize();
      if (mounted) {
        setState(() {}); // Update the UI to show the camera preview
        startLiveDetection(); // Start real-time inference
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
      showErrorDialog("Failed to initialize the camera: $e");
    } finally {
      isCameraInitializing = false;
    }
  }

  bool isDetecting = false;
  void startLiveDetection() {
    if (_cameraController == null || isDetecting) return;

    isDetecting = true;
    _cameraController!.startImageStream((CameraImage cameraImage) async {
      if (!mounted || !isDetecting) return;

      Uint8List imageBytes = _convertCameraImageToBytes(cameraImage);

      final inferenceProvider =
          Provider.of<ImageInferenceProvider>(context, listen: false);
      final result = await inferenceProvider.infer(
          imageBytes, SerializationOutput(json: true));

      final uiImage = await decodeImageFromList(imageBytes);

      if (mounted) {
        setState(() {
          processedImage = uiImage;
          inferenceResult = Future.value(result);
        });
      }
    });
  }

  Uint8List _convertCameraImageToBytes(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final List<int> bytes = [];

    for (final plane in image.planes) {
      bytes.addAll(plane.bytes);
    }

    return Uint8List.fromList(bytes);
  }

  // Show an error dialog for better debugging
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          Button(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void stopCamera() async {
    if (_cameraController != null) {
      await _cameraController?.dispose();
      _cameraController = null;
      setState(() {
        selectedCamera = null;
        isDetecting = false;
        processedImage = null;
      });
    }
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
                                Text("Choose Camera Type"),
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child:
                                      Icon(FluentIcons.chevron_down, size: 12),
                                ),
                              ],
                            ),
                          );
                        },
                        items: availableCamerasList.isNotEmpty
                            ? availableCamerasList.map((camera) {
                                return MenuFlyoutItem(
                                  text: Text(camera.name),
                                  onPressed: () {
                                    setState(() {
                                      selectedCamera = camera;
                                    });
                                    openCamera();
                                  },
                                );
                              }).toList()
                            : [
                                MenuFlyoutItem(
                                  text: const Text("No cameras available"),
                                  onPressed: null,
                                ),
                              ],
                      ),
                      const SizedBox(width: 16),
                      Button(
                        onPressed: stopCamera,
                        child: const Text("Stop Camera"),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: backgroundColor.of(theme),
                  child: Stack(
                    children: [
                      _cameraController != null &&
                              _cameraController!.value.isInitialized
                          ? CameraPreview(
                              _cameraController!) // Live camera feed
                          : const Center(
                              child: Text("No camera selected or initialized.",
                                  style: TextStyle(fontSize: 16)),
                            ),
                      FutureBuilder<ImageInferenceResult>(
                        future: inferenceResult,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && processedImage != null) {
                            return Canvas(
                              image: processedImage!,
                              annotations: snapshot.data!.parseAnnotations(),
                              labelDefinitions: widget.project.labelDefinitions,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ModelProperties(project: widget.project),
      ],
    );
  }
}
