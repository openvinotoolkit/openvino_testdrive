import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inference/header.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/inference/model_info.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/speech_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:inference/inference/speech/message.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';


class SpeechInferencePage extends StatelessWidget {
  final Project project;
  const SpeechInferencePage(this.project, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<PreferenceProvider, SpeechInferenceProvider>(
      update: (_, preferences, speechProvider) {
        if (speechProvider == null) {
          return SpeechInferenceProvider(project, preferences.device);
        }
        if (!speechProvider.sameProps(project, preferences.device)) {
          return SpeechInferenceProvider(project, preferences.device);
        }
        return speechProvider;
      },
      create: (_) {
        return SpeechInferenceProvider(project, null);
      },
      child: Scaffold(
        appBar: const Header(true),
        body: Padding(
          padding: const EdgeInsets.only(left: 58, right: 58, bottom: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: ModelInfo(project),
              ),
              Consumer<SpeechInferenceProvider>(
                builder: (context, inference, child) {
                  return VideoPlayerWrapper(inference);
                }
              ),
            ],
          ),
        )
      )
    );
  }
}
const transcriptionPeriod = 10;

class VideoPlayerWrapper extends StatefulWidget {
  final SpeechInferenceProvider inference;
  const VideoPlayerWrapper(this.inference,  {super.key});

  @override
  State<VideoPlayerWrapper> createState() => _VideoPlayerWrapperState();
}

class _VideoPlayerWrapperState extends State<VideoPlayerWrapper> {
  late final player = Player();
  late final controller = VideoController(player);
  StreamSubscription<Duration>? listener;
  String? file;

  Map<int, FutureOr<String>> transcription = {};

  int subtitleIndex = 0;

  FutureOr<String> getSegment(int index) async {
    final result = widget.inference.transcribe(index * transcriptionPeriod, transcriptionPeriod);

    result.then((m) {
      setState(() {
        transcription[index] = m;
      });
    });

    return result;
  }

  void transcribeEntireVideo() async {
    int i = 0;
    while (true){ // getSegment will throw error at end of file...
      if (!context.mounted) {
        // Context dropped, so stop this.
        break;
      }
      await getSegment(i);
      i++;
    }
  }

  void positionListener(Duration position) {
    int index = (position.inSeconds / transcriptionPeriod).floor();
    if (index != subtitleIndex) {
      setState(() {
          subtitleIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (file != null) {
      initializeVideoAndListeners(file!);
    }
  }

  void initializeVideoAndListeners(String source) async {
    await listener?.cancel();
    player.open(Media(source));
    player.setVolume(0);
    await widget.inference.loadVideo(source);
    transcribeEntireVideo();
    listener = player.stream.position.listen(positionListener);
  }

  void loadFile(String path) {
    setState(() {
        file = path;
        transcription.clear();
        initializeVideoAndListeners(path);
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const DeviceSelector(),
              OutlinedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.video);
                  if (result != null) {
                    loadFile(result.files.single.path!);
                  }
                }, child: const Text("Select video"),
              )
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Video(controller: controller),
                      Subtitles(transcription: transcription, subtitleIndex: subtitleIndex),
                    ]
                  ),
                ),
                TranscriptionSection(transcription: transcription, player: player),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

class Subtitles extends StatelessWidget {
  const Subtitles({
    super.key,
    required this.transcription,
    required this.subtitleIndex,
  });

  final Map<int, FutureOr<String>> transcription;
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
            if (transcription[subtitleIndex] is String) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Text(
                    transcription[subtitleIndex] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = intelGrayReallyDark,
                    )
                  ),
                  Text(
                    transcription[subtitleIndex] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: fontSize
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
