import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inference/inference/speech/message.dart';
import 'package:inference/providers/speech_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:media_kit/media_kit.dart';

class TranscriptionSection extends StatelessWidget {
  const TranscriptionSection({
    super.key,
    required this.transcription,
    required this.player,
  });

  final Map<int, FutureOr<String>> transcription;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Builder(
            builder: (context) {
              final messages = Message.rework(transcription, transcriptionPeriod);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Transcription"),
                  ),
                  ...List<Widget>.from(messages.map((message) {
                     return TranscriptionLine(
                       message: message,
                       player: player,
                     );
                  }))
                ]
              );
            }
          ),
        ),
      ),
    );
  }
}

class TranscriptionLine extends StatelessWidget {
  final Message message;
  final Player player;
  const TranscriptionLine({required this.message, required this.player, super.key});

  String get formattedDuration {
    return "${message.position.inMinutes.toString().padLeft(2, '0')}:${message.position.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(formattedDuration, textAlign: TextAlign.end,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...message.sentences.map((sentence) {
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ElevatedButton(
                    onPressed: () { player.seek(message.position); },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      backgroundColor: intelGrayDark,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    child: Text("$sentence."),
                  ),
                );
              })
            ],
          )
        ],
      ),
    );
  }

}
