import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inference/header.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/inference/model_info.dart';
import 'package:inference/inference/speech/transcript_section.dart';
import 'package:inference/interop/speech_to_text.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/speech_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:inference/utils/drop_area.dart';
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
      if (subtitleIndex > i) {
        i = subtitleIndex;
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
    player.setVolume(0); // TODO: Disable this for release. This is for our sanity
    await widget.inference.loadVideo(source);
    transcribeEntireVideo();
    listener = player.stream.position.listen(positionListener);
  }

  void loadFile(String path) {
    setState(() {
        file = path;
        subtitleIndex = 0;
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
          DropArea(
            type: "video",
            showChild: file != null,
            onUpload: (file) => loadFile(file),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Video(controller: controller),
                Subtitles(transcription: transcription, subtitleIndex: subtitleIndex),
              ]
            ),
          ),
        ],
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
                        ..strokeWidth = 2
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

