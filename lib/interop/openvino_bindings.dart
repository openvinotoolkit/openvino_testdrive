import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart' as pkg_ffi;
import 'package:flutter/foundation.dart';
import 'package:inference/interop/generated_bindings.dart';
import 'package:path/path.dart';

export 'package:inference/interop/generated_bindings.dart';

class SerializationOutput {
  bool csv;
  bool json;
  bool overlay;

  SerializationOutput({this.csv = false, this.json = false, this.overlay = false});

  bool any() => csv || json || overlay;

}

class ModelResponse {
  final String content;
  final Metrics metrics;

  const ModelResponse(this.content, this.metrics);
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
