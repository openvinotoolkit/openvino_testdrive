import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:inference/annotation.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/project.dart';

List tail(List list) {
  final clone = List.from(list);
  clone.removeAt(0);
  return clone;
}

bool annotationIsFullRoi(Annotation annotation, Rectangle roi) {
  if (annotation.shape is Rectangle) {
    final rect = annotation.shape as Rectangle;
    return rect.width == roi.width && rect.height == roi.height;
  }
  return false;
}

Annotation applyChild(Annotation parent, Annotation child) {
  return Annotation(
    parent.labels + child.labels,
    parent.shape
  );
}

void translateChild(Annotation parent, Annotation child) {
  final rect = parent.shape.rectangle;
  final offset = Offset(rect.x, rect.y);
  if (child.shape is Rectangle) {
    final shape = (child.shape as Rectangle);
    shape.x += offset.dx;
    shape.y += offset.dy;
  }
  if (child.shape is Polygon) {
    final shape = (child.shape as Polygon);
    shape.rectangle.x += offset.dx;
    shape.rectangle.y += offset.dy;
    shape.points = shape.points.map((p) => p + offset).toList();
  }
}


Future<ImageInferenceResult> taskChain(List<ImageInference> inferences, Uint8List file, SerializationOutput output, {Rectangle? roi}) async {
  final inference = inferences[0];
  final remainingInferences = List<ImageInference>.from(tail(inferences));
  final taskResult = (roi == null ? await inference.infer(file, output) : await inference.inferRoi(file, output, roi));
  Map<String, dynamic> result = {"predictions": []};
  for (final prediction in taskResult.json!["predictions"]){
    // TODO: accept all predictions as parent
    var annotation = Annotation.fromJson(prediction);
    if (annotation.shape is Rectangle) {
      //TODO: filter empty?
      if (remainingInferences.isNotEmpty) {
        final chainResult = await taskChain(remainingInferences, file, output, roi: annotation.shape as Rectangle);
        for (final chainPrediction in  chainResult.json!["predictions"]) {
          final childAnnotation = Annotation.fromJson(chainPrediction);
          if (annotationIsFullRoi(childAnnotation, annotation.shape.rectangle)) {
            annotation = applyChild(annotation, childAnnotation);
          } else {
            translateChild(annotation, childAnnotation);
            result["predictions"].add(childAnnotation.toMap());
          }
        }
      }
    }
    result["predictions"].add(annotation.toMap());
  }

  return ImageInferenceResult(json: result, imageData: taskResult.imageData);

}

class ImageInferenceProvider extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();
  final Project project;
  final String device;
  List<ImageInference>? _inference;

  List<ImageInference>? get inference => _inference;

  ImageInferenceProvider(this.project, this.device) {
    init();
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

  Future<void> init() async {
    _inference = await Future.wait(
      project.tasks.map((task) {
          final labelDefinitionsJson = jsonEncode(task.labels.map((l) => l.toMap()).toList());
          final modelPath = platformContext.join(project.storagePath, task.modelPaths[0]).replaceAll("\\", "/");
          return ImageInference.init(modelPath, device, task.taskType, labelDefinitionsJson);
      })
    );
    loaded.complete();
    notifyListeners();
  }

  Future<ImageInferenceResult> infer(Uint8List file, SerializationOutput serializationOptions) async {
    return inference![0].infer(file, serializationOptions);
    //return await taskChain(_inference!, file, serializationOptions);
  }

  @override
  void dispose() {
    if (_inference != null) {
      _inference?.forEach((i) => i.close());
    }
    super.dispose();
  }

  void openCamera(int id) {
    // TODO: task chain
    inference![0].openCamera(id);
  }

  void closeCamera() {
    // TODO: task chain
    inference![0].closeCamera();
  }

  void setListener(Function(ImageInferenceResult) fn) {
    // TODO: task chain
    inference![0].setListener(fn);
  }



}
