import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final llm_ov = getBindings();

class LLMInference {

  NativeCallable<LLMInferenceCallbackFunctionFunction>? nativeListener;
  final Pointer<StatusOrLLMInference> instance;
  late bool chatEnabled;

  LLMInference(this.instance) {
    chatEnabled = hasChatTemplate();
  }

  static Future<LLMInference> init(String modelPath, String device) async {
    final result = await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final devicePtr = device.toNativeUtf8();
      final status = llm_ov.llmInferenceOpen(modelPathPtr, devicePtr);
      calloc.free(modelPathPtr);
      calloc.free(devicePtr);

      return status;
    });

    print("${result.ref.status}, ${result.ref.message}");
    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "LLMInference open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return LLMInference(result);
  }

  Future<Message> prompt(String message, double temperature, double topP) async {
    int instanceAddress = instance.ref.value.address;
    final result = await Isolate.run(() {
      final messagePtr = message.toNativeUtf8();
      final status = llm_ov.llmInferencePrompt(Pointer<Void>.fromAddress(instanceAddress), messagePtr, temperature, topP);
      calloc.free(messagePtr);
      return status;
    })
;

    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "LLMInference prompt error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return Message(result.ref.value.toDartString(), result.ref.metrics);
  }

  Future<void> setListener(void Function(String) callback) async{
    int instanceAddress = instance.ref.value.address;
    void localCallback(Pointer<StatusOrString> ptr) {
      if (StatusEnum.fromValue(ptr.ref.status) != StatusEnum.OkStatus) {
        // TODO instead of throw, call an onError callback.
        throw "LLM Callback error: ${ptr.ref.status} ${ptr.ref.message.toDartString()}";
      }
      callback(ptr.ref.value.toDartString());
      llm_ov.freeStatusOrString(ptr);
    }
    nativeListener?.close();
    nativeListener = NativeCallable<LLMInferenceCallbackFunctionFunction>.listener(localCallback);
    final status = llm_ov.llmInferenceSetListener(Pointer<Void>.fromAddress(instanceAddress), nativeListener!.nativeFunction);
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      // TODO instead of throw, call an onError callback.
      throw "LLM setListener error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    llm_ov.freeStatus(status);
  }

  void forceStop() {
    final status = llm_ov.llmInferenceForceStop(instance.ref.value);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "LLM Force Stop error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }

  bool hasChatTemplate() {
    final status = llm_ov.llmInferenceHasChatTemplate(instance.ref.value);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "LLM Chat template error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }

    return status.ref.value;
  }

  void close() {
    llm_ov.llmInferenceForceStop(instance.ref.value);
    nativeListener?.close();
    final status = llm_ov.llmInferenceClose(instance.ref.value);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "Close error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    llm_ov.freeStatus(status);
  }

  void clearHistory() {
    final status = llm_ov.llmInferenceClearHistory(instance.ref.value);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "Clear History: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }
}

class Message {
  final String content;
  final Metrics metrics;

  const Message(this.content, this.metrics);
}
