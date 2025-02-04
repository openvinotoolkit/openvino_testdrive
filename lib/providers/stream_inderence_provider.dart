// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/foundation.dart';
// import 'package:camera/camera.dart';
// import 'package:inference/utils/image_graph_builder.dart';
// import 'package:inference/interop/graph_runner.dart';
// import 'package:inference/interop/image_inference.dart';
// import 'package:inference/interop/openvino_bindings.dart';
// import 'package:inference/project.dart';

// class StreamInferenceProvider extends ChangeNotifier {
//   Completer<void> loaded = Completer<void>();
//   final Project project;
//   final String device;
//   int timestamp = 0;
//   GraphRunner? _inference;
//   GraphRunner? get inference => _inference;

//   CameraController? _cameraController;
//   StreamSubscription<CameraImage>? _cameraStream;

//   StreamInferenceProvider(this.project, this.device);

//   bool _locked = false;

//   void lock() {
//     _locked = true;
//     notifyListeners();
//   }

//   void unlock() {
//     _locked = false;
//     notifyListeners();
//   }

//   bool get isLocked => _locked;
//   bool get isReady => _inference != null;

//   // ✅ Initialize OpenVINO model
//   Future<void> init() async {
//     final graph = await ImageGraphBuilder(project, device).buildGraph();
//     _inference = await GraphRunner.init(graph);
//     loaded.complete();
//     notifyListeners();
//   }

//   // ✅ Start Camera for Live Inference
//   Future<void> startLiveInference(CameraDescription camera) async {
//     _cameraController = CameraController(
//       camera,
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     await _cameraController!.initialize();

//     _cameraStream =
//         _cameraController!.startImageStream((CameraImage image) async {
//       if (_locked || _inference == null) return;
//       lock();

//       // Convert CameraImage to Uint8List (Format conversion may be needed)
//       Uint8List bytes = convertCameraImageToBytes(image);

//       final output =
//           SerializationOutput(); // Adjust based on your inference needs
//       final result = await infer(bytes, output);

//       print("📌 Detection Result: $result");

//       unlock();
//     });

//     notifyListeners();
//   }

//   // ✅ Stop Live Inference
//   Future<void> stopLiveInference() async {
//     await _cameraStream?.cancel();
//     await _cameraController?.dispose();
//     _cameraController = null;
//     notifyListeners();
//   }

//   // ✅ Function to run inference on a single frame
//   Future<ImageInferenceResult> infer(
//       Uint8List file, SerializationOutput output) async {
//     _inference!.queueImage("input", timestamp, file);
//     _inference!
//         .queueSerializationOutput("serialization_output", timestamp, output);
//     timestamp += 1;
//     final result = await _inference!.get();
//     return ImageInferenceResult.fromJson(jsonDecode(result));
//   }

//   @override
//   void dispose() {
//     stopLiveInference();
//     _inference?.close();
//     super.dispose();
//   }

//   // Helper function to convert CameraImage to Uint8List
//   Uint8List convertCameraImageToBytes(CameraImage image) {
//     // Depending on format (YUV, NV21, etc.), conversion is needed
//     return image.planes[0]
//         .bytes; // This is a placeholder. You may need a real converter.
//   }
// }
