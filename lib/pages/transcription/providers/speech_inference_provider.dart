import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/interop/speech_to_text.dart';
import 'package:inference/pages/transcription/utils/metrics.dart';
import 'package:inference/pages/transcription/utils/section.dart';
import 'package:inference/project.dart';


const transcriptionPeriod = 10;

class SpeechInferenceProvider  extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();


  Project? _project;
  String? _device;

  String? _videoPath;
  String? get videoPath => _videoPath;

  bool forceStop = false;

  bool get videoLoaded => _videoPath != null;

  DynamicRangeLoading<FutureOr<TranscriptionModelResponse>>? transcription;
  Future<void>? activeTranscriptionProcess;
  DMetrics? metrics;

  bool get transcriptionComplete {
    return transcription?.complete ?? false;
  }

  String _language = "";

  String get language => _language;
  set language(String val) {
    _language = val;
    notifyListeners();
  }

  SpeechToText? _inference;

  SpeechInferenceProvider(Project? project, String? device) {
    _project = project;
    _device = device;

    if (project != null && device != null) {
      SpeechToText.init(project.storagePath, device).then((instance) {
         _inference = instance;
         loaded.complete();
         notifyListeners();
      });
    }
  }

  void skipTo(int index) {
    transcription!.skipTo(index);
  }

  Future<void> loadVideo(String path) async {
    await loaded.future;
    forceStop = true;
    await activeTranscriptionProcess;
    _videoPath = path;
    final duration = await _inference!.loadVideo(path);
    final sections = (duration / transcriptionPeriod).ceil();
    transcription = DynamicRangeLoading<FutureOr<TranscriptionModelResponse>>(Section(0, sections));
    activeTranscriptionProcess = startTranscribing();
    notifyListeners();
  }

  void addMetrics(TranscriptionModelResponse response) {
    if (metrics == null) {
      metrics = DMetrics.fromCMetrics(response.metrics);
    } else {
      metrics!.addCMetrics(response.metrics);
    }
    notifyListeners();
  }

  Future<void> startTranscribing() async {
    if (transcription == null) {
      throw Exception("Can't transcribe before loading video");
    }

    forceStop = false;

    while (!forceStop && (!transcription!.complete)) {
      if (transcription == null) {
        return;
      }
      await transcription!.process((int i) {
          final request = transcribe(i * transcriptionPeriod, transcriptionPeriod);
          request.then(addMetrics);
          return request;
      });
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  Future<TranscriptionModelResponse> transcribe(int start, int duration) async {
    await loaded.future;
    return await _inference!.transcribe(start, duration, _language);
  }

  bool sameProps(Project? project, String? device) {
    return _project == project && _device == device;
  }

  @override
  void dispose() async {
    forceStop = true;
    await activeTranscriptionProcess;
    super.dispose();
  }

}
