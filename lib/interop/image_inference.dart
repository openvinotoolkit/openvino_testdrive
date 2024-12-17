// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:inference/annotation.dart';
import 'package:inference/interop/openvino_bindings.dart';


class ImageInferenceResult {
  final String? csv;
  final Map<String, dynamic>? json;
  final String? overlay;

  ImageInferenceResult({this.csv, this.json, this.overlay});

  factory ImageInferenceResult.fromJson(Map<String, dynamic> output) {
    return ImageInferenceResult(csv: output["csv"], json: output["json"], overlay: output["overlay"]);
  }

  List<Annotation> parseAnnotations() {
    if (json == null) {
      return [];
    }

    return List<Annotation>.from(json!["predictions"].map((p) => Annotation.fromJson(p)));
  }
}

final ov = getBindings();

class ImageInference {

  Pointer<StatusOrImageInference> instance;
  NativeCallable<ImageInferenceCallbackFunctionFunction>? nativeListener;

  ImageInference(this.instance);


  static Future<ImageInference> init(String modelPath, String device, String taskType,  String labelDefinitionsJson) async {
    final result = await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final taskTypePtr = taskType.toNativeUtf8();
      final devicePtr = device.toNativeUtf8();
      final labelDefinitionsJsonPtr = labelDefinitionsJson.toNativeUtf8();

      final status = ov.imageInferenceOpen(modelPathPtr, taskTypePtr, devicePtr, labelDefinitionsJsonPtr);

      calloc.free(modelPathPtr);
      calloc.free(taskTypePtr);
      calloc.free(devicePtr);
      calloc.free(labelDefinitionsJsonPtr);
      // Symbol not found on macOs for some reason. Not really that big of an issue since the memory leak is really small
      //openvino.freeStatusOrImageInference(status);
      return status;
    });

    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "ImageInference open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return ImageInference(result);
  }

  static Future<bool> serialize(String modelPath, String outputPath ) async {
    return await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final outputPathPtr = outputPath.toNativeUtf8();

      final status = ov.imageInferenceSerializeModel(modelPathPtr, outputPathPtr);

      calloc.free(modelPathPtr);
      calloc.free(outputPathPtr);
      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "Serialize error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
      print("Serialization done");

      return true;
    });
  }

  Future<ImageInferenceResult> infer(Uint8List file, SerializationOutput options) async {
    final result = await Isolate.run(() {
      final _data =  calloc.allocate<Uint8>(file.lengthInBytes);
      final _bytes = _data.asTypedList(file.lengthInBytes);
      _bytes.setRange(0, file.lengthInBytes, file);
      final status = ov.imageInferenceInfer(instance.ref.value, _data, file.lengthInBytes, options.json, options.csv, options.overlay);
      calloc.free(_data);
      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "ImageInference infer error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }

      final output = status.ref.value.toDartString();
      ov.freeStatusOrString(status);
      return output;
    });

    return ImageInferenceResult.fromJson(jsonDecode(result));
  }

  Future<ImageInferenceResult> inferRoi(Uint8List file, SerializationOutput options, Rectangle roi) async {
    final result = await Isolate.run(() {
      final _data =  calloc.allocate<Uint8>(file.lengthInBytes);
      final _bytes = _data.asTypedList(file.lengthInBytes);
      _bytes.setRange(0, file.lengthInBytes, file);
      final status = ov.imageInferenceInferRoi(instance.ref.value, _data, file.lengthInBytes, roi.x.toInt(), roi.y.toInt(), roi.width.toInt(), roi.height.toInt(), options.json, options.csv, options.overlay);
      calloc.free(_data);
      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "ImageInference infer error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }

      final output = status.ref.value.toDartString();
      ov.freeStatusOrString(status);
      return output;
    });

    return ImageInferenceResult.fromJson(jsonDecode(result));
  }

  void inferAsync(Uint8List file, String id, SerializationOutput options) {
      final _data =  calloc.allocate<Uint8>(file.lengthInBytes);
      final _bytes = _data.asTypedList(file.lengthInBytes);
      final idPtr = id.toNativeUtf8();
      _bytes.setRange(0, file.lengthInBytes, file);
      final status = ov.imageInferenceInferAsync(instance.ref.value, idPtr, _data, file.lengthInBytes, options.json, options.csv, options.overlay);
      print("inferAsync: ${status.ref.status}");
      calloc.free(idPtr);
      calloc.free(_data);
  }

  Future<void> setListener(Function(ImageInferenceResult) callback) async{
    int instanceAddress = instance.ref.value.address;
    void wrapCallback(Pointer<StatusOrString> ptr) {
      if (StatusEnum.fromValue(ptr.ref.status) != StatusEnum.OkStatus) {
        // TODO instead of throw, call an onError callback.
        throw "ImageInference infer error: ${ptr.ref.status} ${ptr.ref.message.toDartString()}";
      }
      callback(ImageInferenceResult.fromJson(jsonDecode(ptr.ref.value.toDartString())));
      ov.freeStatusOrString(ptr);
    }
    nativeListener?.close();
    nativeListener = NativeCallable<ImageInferenceCallbackFunctionFunction>.listener(wrapCallback);
    final status = ov.imageInferenceSetListener(Pointer<Void>.fromAddress(instanceAddress), nativeListener!.nativeFunction);
    ov.freeStatus(status);
  }

  void openCamera(int device) {
    int instanceAddress = instance.ref.value.address;
    final status = ov.imageInferenceOpenCamera(Pointer<Void>.fromAddress(instanceAddress), device);
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "OpenCamera error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }

  void closeCamera() {
    print("Closing camera");
    int instanceAddress = instance.ref.value.address;
    final status = ov.imageInferenceStopCamera(Pointer<Void>.fromAddress(instanceAddress));
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "OpenCamera error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }

  static void setupFont(String fontPath) {
    final fontPathPtr = fontPath.toNativeUtf8();
    final status = ov.load_font(fontPathPtr);
    calloc.free(fontPathPtr);
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "Font load error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }

  void close() {
    closeCamera();
    nativeListener?.close();
    final status = ov.imageInferenceClose(instance.ref.value);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "Close error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    ov.freeStatus(status);
  }

}
