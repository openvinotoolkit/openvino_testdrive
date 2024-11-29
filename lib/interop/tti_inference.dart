import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final tti_ov = getBindings();

class TTIInference {
  final Pointer<StatusOrTTIInference> instance;
  late bool chatEnabled;

  TTIInference(this.instance) {
    chatEnabled = hasModelIndex();
  }

  static Future<TTIInference> init(String modelPath, String device) async {
    final result = await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final devicePtr = device.toNativeUtf8();
      final status = tti_ov.ttiInferenceOpen(modelPathPtr, devicePtr);
      calloc.free(modelPathPtr);
      calloc.free(devicePtr);

      return status;
    });

    print("${result.ref.status}, ${result.ref.message}");
    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "TTIInference open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return TTIInference(result);
  }

  Future<TTIModelResponse> prompt(
      String message, int width, int height, int rounds) async {
    int instanceAddress = instance.ref.value.address;
    final result = await Isolate.run(() {
      final messagePtr = message.toNativeUtf8();
      final status = tti_ov.ttiInferencePrompt(
          Pointer<Void>.fromAddress(instanceAddress),
          messagePtr,
          width,
          height,
          rounds);
      calloc.free(messagePtr);
      return status;
    });

    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "TTIInference prompt error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return TTIModelResponse(
        result.ref.value.toDartString(), result.ref.metrics);
  }

  bool hasModelIndex() {
    final status = tti_ov.ttiInferenceHasModelIndex(instance.ref.value);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "TTI Chat template error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }

    return status.ref.value;
  }

  void close() {
    final status = tti_ov.ttiInferenceClose(instance.ref.value);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "Close error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    tti_ov.freeStatus(status);
  }
}
