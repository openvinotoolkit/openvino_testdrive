// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0


//EXPORT StatusOrSentences* pdfExtractSentences(const char* pdf_path);

import 'dart:isolate';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();


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
