
//EXPORT StatusOrSentences* pdfExtractSentences(const char* pdf_path);

import 'dart:isolate';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();


Future<List<String>> getSentencesFromPdf(String path) {
  return Isolate.run(() {
    final pathPtr = path.toNativeUtf8();
    final status = ov.pdfExtractSentences(pathPtr);
    calloc.free(pathPtr);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "pdfExtractSentences error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }

    List<String> sentences = [];

    for (int i = 0; i < status.ref.size; i++) {
      sentences.add(status.ref.value[i].sentence.toDartString());
    }

    ov.freeStatusOrSentences(status);
    return sentences;
  });
}


Future<String> getTextFromPdf(String path) {
  return Isolate.run(() {
    final pathPtr = path.toNativeUtf8();
    final status = ov.pdfExtractText(pathPtr);
    calloc.free(pathPtr);

    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "pdfExtractText error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }

    final output = status.ref.value.toDartString();
    ov.freeStatusOrString(status);
    return output;
  });
}
