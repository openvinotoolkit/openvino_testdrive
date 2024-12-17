// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart';

class Subtitles extends StatelessWidget {
  const Subtitles({
    super.key,
    required this.transcription,
    required this.subtitleIndex,
  });

  final Map<int, FutureOr<TranscriptionModelResponse>>? transcription;
  final int subtitleIndex;

  static const double fontSize = 18;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 60),
      child: SizedBox(
        height: 100,
        child: Builder(
          builder: (context) {
            if (transcription == null ) {
              return Container();
            }
            if (transcription![subtitleIndex] is TranscriptionModelResponse) {
              final text = (transcription![subtitleIndex] as TranscriptionModelResponse).text;
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Text(text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.black,
                    )
                  ),
                  Text(text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                    )
                  )
                ],
              );
            }
            return Container();
          }
        ),
      ),
    );
  }
}
