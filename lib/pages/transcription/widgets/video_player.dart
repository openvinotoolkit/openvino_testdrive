import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/pages/transcription/widgets/subtitles.dart';
import 'package:inference/pages/transcription/widgets/win_video_player.dart';
import 'package:provider/provider.dart';
import 'package:video_player_win/video_player_win.dart';

class VideoPlayerWrapper extends StatefulWidget {
  final String filePath;
  const VideoPlayerWrapper({super.key, required this.filePath});

  @override
  State<VideoPlayerWrapper> createState() => _VideoPlayerWrapperState();
}

class _VideoPlayerWrapperState extends State<VideoPlayerWrapper> {
  int subtitleIndex = 0;

  void positionListener(Duration position) async {
    final seconds = position.inSeconds;
    final index = (seconds / transcriptionPeriod).floor();
    if (index != subtitleIndex) {
      final inference = Provider.of<SpeechInferenceProvider>(context, listen: false);
      inference.skipTo(index);
      setState(() {
          subtitleIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        WinVideoPlayerWrapper(
          file: widget.filePath,
          onPosition: positionListener,
        ),
        Consumer<SpeechInferenceProvider>(
          builder: (context, inference, child) {
            return Subtitles(
              transcription: inference.transcription?.data,
              subtitleIndex: subtitleIndex,
            );
          }
        ),
      ],
    );
  }
}
