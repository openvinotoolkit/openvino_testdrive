// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:isolate';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();

class InteropUtils {
  static Future<bool> serialize(String modelPath, String outputPath ) async {
    return await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final outputPathPtr = outputPath.toNativeUtf8();

      final status = ov.ModelAPISerializeModel(modelPathPtr, outputPathPtr);

      calloc.free(modelPathPtr);
      calloc.free(outputPathPtr);
      if (status.ref.status != StatusEnum.OkStatus) {
        throw "Serialize error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
      print("Serialization done");

      return true;
    });
  }
}
