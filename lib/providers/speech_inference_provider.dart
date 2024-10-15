import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inference/inference/speech/section.dart';
import 'package:inference/interop/speech_to_text.dart';
import 'package:inference/project.dart';

const transcriptionPeriod = 10;

class SpeechInferenceProvider  extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

  String? _videoPath;
  String? get videoPath => _videoPath;

  bool get videoLoaded => _videoPath != null;

  DynamicRangeLoading<FutureOr<String>>? _transcription;
  Map<int, FutureOr<String>>? get transcription => _transcription?.data;

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
    _transcription!.skipTo(index);
  }

  Future<void> loadVideo(String path) async {
    await loaded.future;
    _videoPath = path;
    final duration = await _inference!.loadVideo(path);
    final sections = (duration / transcriptionPeriod).ceil();
    _transcription = DynamicRangeLoading<FutureOr<String>>(Section(0, sections));
    notifyListeners();
  }

  Future<void> startTranscribing() async {
    if (_transcription == null) {
      throw Exception("Can't transcribe before loading video");
    }

    while (!_transcription!.complete) {
      if (_transcription == null) {
        return;
      }
      await _transcription!.process((int i) {
          return transcribe(i * transcriptionPeriod, transcriptionPeriod);
      });
      notifyListeners();
    }
  }

  Future<String> transcribe(int start, int duration) async {
    await loaded.future;
    return await _inference!.transcribe(start, duration, _language);
  }

  bool sameProps(Project? project, String? device) {
    return _project == project && _device == device;
  }

}
