// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

bool isImage(String path) {
  final mimeType = lookupMimeType(path);
  if (mimeType == null) {
    return false;
  }
  return mimeType.startsWith('image/');
}

class Progress {
  int current = 0;
  final int total;

  Progress(this.total);

  double percentage() {
    return current.toDouble() / total;
  }
}
enum BatchInferenceState { ready, running, done }

class BatchInferenceProvider extends ChangeNotifier {
  ImageInferenceProvider imageInference;
  bool _forceStop = false;

  String? _sourceFolder;

  String? get sourceFolder => _sourceFolder;
  set sourceFolder(String? v) {
    _sourceFolder = v;
    notifyListeners();
  }

  String? _destinationFolder;

  String? get destinationFolder => _destinationFolder;
  set destinationFolder(String? v) {
    _destinationFolder = v;
    notifyListeners();
  }

  SerializationOutput _output;

  SerializationOutput get output => _output;
  set output(SerializationOutput v)  {
    _output = v;
    notifyListeners();
  }

  Progress? _progress;
  Progress? get progress => _progress;
  set progress(Progress? p) {
    _progress = p;
    notifyListeners();
  }

  void imageProcessed() {
    _progress?.current += 1;
    notifyListeners();
  }

  BatchInferenceState get state {
    if (progress == null ) {
      return BatchInferenceState.ready;
    } else if (progress!.current < progress!.total) {
      return BatchInferenceState.running;
    } else {
      return BatchInferenceState.done;
    }
  }

  BatchInferenceProvider(this.imageInference, this._output);

  void stop() {
    _forceStop = true;
  }

  void start() async {
    _forceStop = false;
    await imageInference.loaded.future;
    final platformContext = Context(style: Style.platform);
    List<List<dynamic>> rows = [];
    const encoder = JsonEncoder.withIndent("  ");
    const converter = CsvToListConverter();

    final files = await getFiles();

    progress = Progress(files.length);

    for (final file in files) {
      if (_forceStop) {
        progress = null;
        break;
      }
      final outputFilename = platformContext.basename(file.path);
      Uint8List imageData = File(file.path).readAsBytesSync();
      final inferenceResult = await imageInference.infer(imageData, output);
      await Future.delayed(Duration.zero); // For some reason ui does not update even though it's running in Isolate. This gives the UI time to run that code.
      final outputPath = platformContext.join(destinationFolder!, outputFilename);
      if (output.overlay) {
        final outputFile = File(outputPath);
        final decodedImage = base64Decode(inferenceResult.overlay!);
        outputFile.writeAsBytes(decodedImage);
      }
      if (output.csv) {
        var csvOutput = converter.convert(inferenceResult.csv);
        rows.addAll(csvOutput.map((row) {
            row.insert(0, outputFilename);
            return row;
        }));
      }
      if (output.json) {
        final outputFile = File(setExtension(outputPath, ".json"));
        outputFile.writeAsString(encoder.convert(inferenceResult.json));
      }

      imageProcessed();
    }

    if (output.csv) {
      List<String> columns = ["filename", "label_name", "label_id", "probability", "shape_type", "x", "y", "width", "height", "area", "angle"];
      rows.insert(0, columns);
      const converter = ListToCsvConverter();
      final outputPath = platformContext.join(destinationFolder!, "predictions.csv");
      File(outputPath).writeAsStringSync(converter.convert(rows));
    }
    print("done");
  }

  bool validSetup() {
    return sourceFolder != null &&
    destinationFolder != null &&
    output.any();
  }

  Future<List<FileSystemEntity>> getFiles() async {
    if (!validSetup()){
      throw Exception("Setup was invalid");
    }
    final dir = Directory(sourceFolder!);
    final listener = dir.list(recursive: true);
    return listener.where((b) => isImage(b.path)).toList();
  }

}
