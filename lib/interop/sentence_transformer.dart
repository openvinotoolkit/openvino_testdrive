import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();

class SentenceTransformer {

  final Pointer<StatusOrSentenceTransformer> instance;
  SentenceTransformer(this.instance);

  static Future<SentenceTransformer> init(String modelPath, String device) async {
    final result = await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final devicePtr = device.toNativeUtf8();
      final status = ov.sentenceTransformerOpen(modelPathPtr, devicePtr);
      calloc.free(modelPathPtr);
      calloc.free(devicePtr);
      return status;
    });


    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "SentenceTransformer open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }
    return SentenceTransformer(result);
  }

  Future<List<double>> generate(String prompt) async{

    int instanceAddress = instance.ref.value.address;
    final status = await Isolate.run(() {
      final promptPtr = prompt.toNativeUtf8();
      final status = ov.sentenceTransformerGenerate(Pointer<Void>.fromAddress(instanceAddress), promptPtr);
      calloc.free(promptPtr);
      return status;
    });

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "SentenceTransformer generate error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }

    List<double> data = [];
    for (int i = 0; i < status.ref.size; i++) {
      data.add(status.ref.value[i]);
    }

    ov.freeStatusOrEmbeddings(status);

    return data;
  }

  void close() {
    final status = ov.sentenceTransformerClose(instance.ref.value);
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "Close error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
    ov.freeStatus(status);
  }
}
