// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:path/path.dart';

export 'package:inference/interop/generated_bindings.dart';

class SerializationOutput {
  bool csv;
  bool json;
  bool overlay;
  bool source;

  SerializationOutput({this.csv = false, this.json = false, this.overlay = false, this.source = false});

  bool any() => csv || json || overlay;

}

class Chunk {
  final double start;
  final double end;
  final String text;
  const Chunk(this.start, this.end, this.text);
}

class TranscriptionModelResponse {
  final List<Chunk> chunks;
  final Metrics metrics;
  final String text;
  const TranscriptionModelResponse(this.chunks, this.metrics, this.text);
}

class ModelResponse {
  final String content;
  final Metrics metrics;

  const ModelResponse(this.content, this.metrics);
}

class GenericMetrics {
  final double loadTime;
  final double generationTime;

  const GenericMetrics(this.loadTime, this.generationTime);
  factory GenericMetrics.fromTTIMetrics(TTIMetrics metrics) {
    return GenericMetrics(metrics.load_time, metrics.generate_time);
  }
}

class TTIModelResponse {
  final String content;
  final GenericMetrics metrics;
  final int step;
  final int rounds;

  const TTIModelResponse(this.content, this.metrics, this.step, this.rounds);
}

class VLMModelResponse {
  final String content;
  final VLMMetrics metrics;

  const VLMModelResponse(this.content, this.metrics);
}


String getLibraryPath() {
  if (Platform.isWindows) {
    return "windows_bindings.dll";
  } else if (Platform.isMacOS) {
    return "libmacos_bindings.dylib";
  } else {
    if (kDebugMode) {
      return "bindings/liblinux_bindings.so";
    } else {
      final executableFolder = dirname(Platform.resolvedExecutable);
      return "$executableFolder/data/flutter_assets/bindings/liblinux_bindings.so";
    }
  }
}

final lookup = ffi.DynamicLibrary.open(getLibraryPath()).lookup;

OpenVINO getBindings() => OpenVINO.fromLookup(lookup);
