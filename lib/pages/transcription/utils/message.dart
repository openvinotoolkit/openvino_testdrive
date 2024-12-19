// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:inference/interop/openvino_bindings.dart';

class Message {
  String message;
  final Duration position;

  Message(this.message, this.position);

  static List<Message> parse(Map<int, FutureOr<TranscriptionModelResponse>> transcriptions, int indexDuration) {
    final indices = transcriptions.keys.toList()..sort();
    if (indices.isEmpty) {
      return [];
    }

    List<Message> output = [];

    bool lastChunkIsOpenEnded  = false;

    for (int i in indices) {
      if (transcriptions[i] is Future) {
        continue;
      }
      final part = transcriptions[i] as TranscriptionModelResponse;
      for (final chunk in part.chunks) {
        String text = chunk.text;
        if (lastChunkIsOpenEnded) {
          output.last.message += text;
        } else {
          output.add(Message(text.substring(1), Duration(seconds: chunk.start.toInt())));
        }
        lastChunkIsOpenEnded = text[text.length - 1] != ".";
      }
    }
    return output;
  }
}
