// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0


// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/device.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();

class GraphRunner {
  final Pointer<StatusOrGraphRunner> instance;
  NativeCallable<ImageInferenceCallbackFunctionFunction>? nativeListener;

  GraphRunner(this.instance);

  static Future<GraphRunner> init(String graph) async {
    final result = await Isolate.run(() {
      final graphPtr = graph.toNativeUtf8();
      final status = ov.graphRunnerOpen(graphPtr);
      calloc.free(graphPtr);
      return status;
    });

    if (result.ref.status != StatusEnum.OkStatus) {
      throw "GraphRunner::Init error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return GraphRunner(result);
  }

  int getTimestamp() {
    final status = ov.graphRunnerGetTimestamp(instance.ref.value);

    if (status.ref.status != StatusEnum.OkStatus) {
      throw "GraphRunner::get error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    final content = status.ref.value;
    ov.freeStatusOrInt(status);
    return content;
  }

  Future<String> get() async {
    int instanceAddress = instance.ref.value.address;
    return await Isolate.run(() {
      final status = ov.graphRunnerGet(Pointer<Void>.fromAddress(instanceAddress));

      if (status.ref.status != StatusEnum.OkStatus) {
        throw "GraphRunner::get error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
      final content = status.ref.value.toDartString();
      ov.freeStatusOrString(status);
      return content;
    });
  }

  Future<void> setCameraResolution(Resolution resolution) async {
    int instanceAddress = instance.ref.value.address;
    return await Isolate.run(() {
      final status = ov.graphRunnerSetCameraResolution(Pointer<Void>.fromAddress(instanceAddress), resolution.width, resolution.height);

      if (status.ref.status != StatusEnum.OkStatus) {
        throw "GraphRunner::setCameraResolution error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
      ov.freeStatus(status);
    });
  }

  Future<void> startCamera(int deviceIndex, Function(String) callback, SerializationOutput output) async {
    void wrapCallback(Pointer<StatusOrString> ptr) {
      if (ptr.ref.status != StatusEnum.OkStatus) {
        // TODO(RHeckerIntel): instead of throw, call an onError callback.
        throw "ImageInference infer error: ${ptr.ref.status} ${ptr.ref.message.toDartString()}";
      }
      callback(ptr.ref.value.toDartString());
      ov.freeStatusOrString(ptr);
    }

    nativeListener?.close();
    nativeListener = NativeCallable<ImageInferenceCallbackFunctionFunction>.listener(wrapCallback);
    final nativeFunction = nativeListener!.nativeFunction;
    final status = ov.graphRunnerStartCamera(instance.ref.value, deviceIndex, nativeFunction, output.json, output.csv, output.overlay, output.source);
    if (status.ref.status != StatusEnum.OkStatus) {
      throw "GraphRunner::StartCamera error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }
  Future<void> stopCamera() async {
    int instanceAddress = instance.ref.value.address;
    await Isolate.run(() {
      final status = ov.graphRunnerStopCamera(Pointer<Void>.fromAddress(instanceAddress));
      switch(status.ref.status) {
        case StatusEnum.OkStatus:
        case StatusEnum.ErrorStatus: //Fail gracefully since race condition could happen with stopping the camera and we dont care about that
          break;
        default:
          throw "GraphRunner::StopCamera error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> queueImage(String nodeName, int timestamp, Uint8List file) async {

    int instanceAddress = instance.ref.value.address;
    await Isolate.run(() {
      final _data =  calloc.allocate<Uint8>(file.lengthInBytes);
      final _bytes = _data.asTypedList(file.lengthInBytes);
      _bytes.setRange(0, file.lengthInBytes, file);
      final nodeNamePtr = nodeName.toNativeUtf8();
      final status = ov.graphRunnerQueueImage(Pointer<Void>.fromAddress(instanceAddress), nodeNamePtr, timestamp, _data, file.lengthInBytes);
      calloc.free(nodeNamePtr);

      if (status.ref.status != StatusEnum.OkStatus) {
        throw "QueueImage error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> queueSerializationOutput(String nodeName, int timestamp, SerializationOutput output) async {
    int instanceAddress = instance.ref.value.address;
    await Isolate.run(() {
      final nodeNamePtr = nodeName.toNativeUtf8();
      final status = ov.graphRunnerQueueSerializationOutput(Pointer<Void>.fromAddress(instanceAddress), nodeNamePtr, timestamp, output.json, output.csv, output.overlay, output.source);
      calloc.free(nodeNamePtr);

      if (status.ref.status != StatusEnum.OkStatus) {
        throw "QueueSerializationOutput error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> stop() async {
    int instanceAddress = instance.ref.value.address;
    await Isolate.run(() {
      final status = ov.graphRunnerStop(Pointer<Void>.fromAddress(instanceAddress));
      if (status.ref.status != StatusEnum.OkStatus) {
        throw "GraphRunner::stop error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }
}
