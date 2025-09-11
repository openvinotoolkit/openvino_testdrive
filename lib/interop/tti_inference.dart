// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ttiOV = getBindings();

class TTIInference {
  NativeCallable<TTIInferenceCallbackFunctionFunction>? nativeListener;
  final Pointer<StatusOrTTIInference> instance;
  late bool chatEnabled;

  TTIInference(this.instance) {
    chatEnabled = hasModelIndex();
  }

  static Future<TTIInference> init(String modelPath, String device) async {
    final result = await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final devicePtr = device.toNativeUtf8();
      final status = ttiOV.ttiInferenceOpen(modelPathPtr, devicePtr);
      calloc.free(modelPathPtr);
      calloc.free(devicePtr);

      return status;
    });

    print("${result.ref.status}, ${result.ref.message}");
    if (result.ref.status != StatusEnum.OkStatus) {
      throw "TTIInference open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return TTIInference(result);
  }


  Future<void> setListener(void Function(TTIModelResponse) callback) async{
    int instanceAddress = instance.ref.value.address;
    void localCallback(Pointer<StatusOrTTIModelResponse> ptr) {
      if (ptr.ref.status != StatusEnum.OkStatus) {
        // TODO(RHeckerIntel): instead of throw, call an onError callback.
        throw "TTI Callback error: ${ptr.ref.status} ${ptr.ref.message.toDartString()}";
      }
      callback(TTIModelResponse(ptr.ref.value.toDartString(), GenericMetrics.fromTTIMetrics(ptr.ref.metrics), ptr.ref.step, ptr.ref.num_step));
      ttiOV.freeStatusOrTTIModelResponse(ptr);
    }
    nativeListener?.close();
    nativeListener = NativeCallable<TTIInferenceCallbackFunctionFunction>.listener(localCallback);
    final status = ttiOV.ttiInferenceSetListener(Pointer<Void>.fromAddress(instanceAddress), nativeListener!.nativeFunction);
    if (status.ref.status != StatusEnum.OkStatus) {
      // TODO(RHeckerIntel): instead of throw, call an onError callback.
      throw "LLM setListener error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    ttiOV.freeStatus(status);
  }

  Future<TTIModelResponse> prompt(
      String message, int width, int height, int rounds) async {
    int instanceAddress = instance.ref.value.address;
    final result = await Isolate.run(() {
      final messagePtr = message.toNativeUtf8();
      final status = ttiOV.ttiInferencePrompt(
          Pointer<Void>.fromAddress(instanceAddress),
          messagePtr,
          width,
          height,
          rounds);
      calloc.free(messagePtr);
      return status;
    });

    if (result.ref.status != StatusEnum.OkStatus) {
      throw "TTIInference prompt error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    final response = TTIModelResponse(result.ref.value.toDartString(), GenericMetrics.fromTTIMetrics(result.ref.metrics), result.ref.step, result.ref.num_step);
    ttiOV.freeStatusOrTTIModelResponse(result);
    return response;
  }

  bool hasModelIndex() {
    final status = ttiOV.ttiInferenceHasModelIndex(instance.ref.value);

    if (status.ref.status != StatusEnum.OkStatus) {
      throw "TTI Chat template error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }

    return status.ref.value;
  }

  Future<void> forceStop() async {
    int instanceAddress = instance.ref.value.address;
    await Isolate.run(() {
      final status = ttiOV.ttiInferenceForceStop(Pointer<Void>.fromAddress(instanceAddress));

      if (status.ref.status != StatusEnum.OkStatus) {
        throw "TTI Force Stop error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  void close() async {
    int instanceAddress = instance.ref.value.address;
    await Isolate.run(() {
      final status = ttiOV.ttiInferenceClose(Pointer<Void>.fromAddress(instanceAddress));

      if (status.ref.status != StatusEnum.OkStatus) {
        throw "Close error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
      ttiOV.freeStatus(status);
    });
    nativeListener?.close();
  }
}
