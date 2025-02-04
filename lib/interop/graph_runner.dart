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

    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "GraphRunner::Init error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return GraphRunner(result);
  }

  Future<String> get() async {
    return await Isolate.run(() {
      final status = ov.graphRunnerGet(instance.ref.value);

      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "GraphRunner::get error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
      final content = status.ref.value.toDartString();
      ov.freeStatusOrString(status);
      return content;
    });
  }

  Future<void> startCamera(int deviceIndex, Function(String) callback, SerializationOutput output) async {
    void wrapCallback(Pointer<StatusOrString> ptr) {
      if (StatusEnum.fromValue(ptr.ref.status) != StatusEnum.OkStatus) {
        // TODO(RHeckerIntel): instead of throw, call an onError callback.
        throw "ImageInference infer error: ${ptr.ref.status} ${ptr.ref.message.toDartString()}";
      }
      callback(ptr.ref.value.toDartString());
      ov.freeStatusOrString(ptr);
    }

    nativeListener?.close();
    nativeListener = NativeCallable<ImageInferenceCallbackFunctionFunction>.listener(wrapCallback);
    final nativeFunction = nativeListener!.nativeFunction;
    final status = ov.graphRunnerStartCamera(instance.ref.value, deviceIndex, nativeFunction, output.json, output.csv, output.overlay);
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "GraphRunner::StartCamera error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }
  Future<void> stopCamera() async {
    int instanceAddress = instance.ref.value.address;
    await Isolate.run(() {
      final status = ov.graphRunnerStopCamera(Pointer<Void>.fromAddress(instanceAddress));
      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "GraphRunner::StopCamera error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> queueImage(String nodeName, int timestamp, Uint8List file) async {
    await Isolate.run(() {
      final _data =  calloc.allocate<Uint8>(file.lengthInBytes);
      final _bytes = _data.asTypedList(file.lengthInBytes);
      _bytes.setRange(0, file.lengthInBytes, file);
      final nodeNamePtr = nodeName.toNativeUtf8();
      final status = ov.graphRunnerQueueImage(instance.ref.value, nodeNamePtr, timestamp, _data, file.lengthInBytes);
      calloc.free(nodeNamePtr);

      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "QueueImage error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> queueSerializationOutput(String nodeName, int timestamp, SerializationOutput output) async {
    await Isolate.run(() {
      final nodeNamePtr = nodeName.toNativeUtf8();
      final status = ov.graphRunnerQueueSerializationOutput(instance.ref.value, nodeNamePtr, timestamp, output.json, output.csv, output.overlay);
      calloc.free(nodeNamePtr);

      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "QueueSerializationOutput error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> stop() async {
    final status = ov.graphRunnerStop(instance.ref.value);
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "QueueSerializationOutput error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }

  void close() {
    stop();
  }
}
