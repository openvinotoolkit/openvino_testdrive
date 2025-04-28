// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final vlmOV = getBindings();

class VLMInference {
  NativeCallable<VLMInferenceCallbackFunctionFunction>? nativeListener;
  final Pointer<StatusOrVLMInference> instance;
  late bool chatEnabled;

  VLMInference(this.instance) {
    chatEnabled = true;
  }

  static Future<VLMInference> init(String modelPath, String device) async {
    final result = await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final devicePtr = device.toNativeUtf8();
      final status = vlmOV.vlmInferenceOpen(modelPathPtr, devicePtr);
      calloc.free(modelPathPtr);
      calloc.free(devicePtr);

      return status;
    });

    print("${result.ref.status}, ${result.ref.message}");
    if (result.ref.status != StatusEnum.OkStatus) {
      throw "VLMInference open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return VLMInference(result);
  }

  Future<void> setListener(void Function(String) callback) async{
    int instanceAddress = instance.ref.value.address;
    void localCallback(Pointer<StatusOrString> ptr) {
      if (ptr.ref.status != StatusEnum.OkStatus) {
        // TODO(RHeckerIntel): instead of throw, call an onError callback.
        throw "VLM Callback error: ${ptr.ref.status} ${ptr.ref.message.toDartString()}";
      }
      callback(ptr.ref.value.toDartString());
      vlmOV.freeStatusOrString(ptr);
    }
    nativeListener?.close();
    nativeListener = NativeCallable<VLMInferenceCallbackFunctionFunction>.listener(localCallback);
    final status = vlmOV.vlmInferenceSetListener(Pointer<Void>.fromAddress(instanceAddress), nativeListener!.nativeFunction);
    if (status.ref.status != StatusEnum.OkStatus) {
      // TODO(RHeckerIntel): instead of throw, call an onError callback.
      throw "VLM setListener error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    vlmOV.freeStatus(status);
  }


  Future<VLMModelResponse> prompt(
      String message, int maxNewTokens) async {
    int instanceAddress = instance.ref.value.address;
    final result = await Isolate.run(() {
      final messagePtr = message.toNativeUtf8();
      final status = vlmOV.vlmInferencePrompt(
          Pointer<Void>.fromAddress(instanceAddress),
          messagePtr,
          maxNewTokens);
      calloc.free(messagePtr);
      return status;
    });

    if (result.ref.status != StatusEnum.OkStatus) {
      var msg = result.ref.message;
      var status = result.ref.status;
      var dStr = msg.toDartString();

      throw "VLMInference prompt error: $status $dStr";
    }

    return VLMModelResponse(
        result.ref.value.toDartString(), result.ref.metrics);
  }


  void setImagePaths(List<String> paths) {
    // Convert Dart strings to C strings
    final cStrings = paths.map((str) => str.toNativeUtf8()).toList();

    // Create a pointer to the array of C strings
    final pointerToCStrings = malloc<Pointer<Utf8>>(cStrings.length);
    for (var i = 0; i < cStrings.length; i++) {
      pointerToCStrings[i] = cStrings[i];
    }

    final status = vlmOV.vlmInferenceSetImagePaths(instance.ref.value, pointerToCStrings, cStrings.length);

    if (status.ref.status != StatusEnum.OkStatus) {
      throw "Close error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    vlmOV.freeStatus(status);
  }

  void forceStop() {
    final status = vlmOV.vlmInferenceStop(instance.ref.value);

    if (status.ref.status != StatusEnum.OkStatus) {
      throw "VLM Force Stop error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }


  void close() {
    final status = vlmOV.vlmInferenceClose(instance.ref.value);

    if (status.ref.status != StatusEnum.OkStatus) {
      throw "Close error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    vlmOV.freeStatus(status);
  }
}
