import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inference/interop/speech_to_text.dart';
import 'package:inference/project.dart';

class SpeechInferenceProvider  extends ChangeNotifier {
  Completer<void> loaded = Completer<void>();

  Project? _project;
  String? _device;

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

  Future<void> loadVideo(String path) async {
    await loaded.future;
    await _inference!.loadVideo(path);
  }

  Future<String> transcribe(int start, int duration) async {
    await loaded.future;
    return await _inference!.transcribe(start, duration);
  }

  bool sameProps(Project? project, String? device) {
    return _project == project && _device == device;
  }

}
