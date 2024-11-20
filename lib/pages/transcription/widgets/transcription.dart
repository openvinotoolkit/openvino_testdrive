import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/pages/transcription/utils/message.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/theme_fluent.dart';

String formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = totalSeconds % 60;

  final minutesString = '$minutes'.padLeft(2, '0');
  final secondsString = '$seconds'.padLeft(2, '0');
  return '$minutesString:$secondsString';
}



class Transcription extends StatelessWidget {
  final Map<int, FutureOr<TranscriptionModelResponse>>? transcription;
  final Function(Duration)? onSeek;
  const Transcription({super.key, this.transcription, this.onSeek});

  @override
  Widget build(BuildContext context) {
    if (transcription == null) {
      return Container();
    }

    final messages = Message.parse(transcription!, transcriptionPeriod);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final message in messages)
              TranscriptionMessage(message: message, onSeek: onSeek)
          ],
        ),
      ),
    );
  }
}

class TranscriptionMessage extends StatefulWidget {
  final Function(Duration)? onSeek;
  final Message message;

  const TranscriptionMessage({super.key, required this.message, this.onSeek});

  @override
  State<TranscriptionMessage> createState() => _TranscriptionMessageState();
}

class _TranscriptionMessageState extends State<TranscriptionMessage> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return MouseRegion(
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: GestureDetector(
        onTap: () {
          widget.onSeek?.call(widget.message.position);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Text(formatDuration(widget.message.position.inSeconds),
                  style: TextStyle(
                    fontSize: 9,
                    color: subtleTextColor.of(theme),
                  )
                )
              ),
              Container(
                decoration: BoxDecoration(
                  color: hover ? subtleTextColor.of(theme).withOpacity(0.3) : null,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(widget.message.message)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
