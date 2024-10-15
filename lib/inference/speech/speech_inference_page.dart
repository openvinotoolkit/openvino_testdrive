import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inference/header.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/inference/model_info.dart';
import 'package:inference/inference/speech/transcript_page.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/speech_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:inference/utils/drop_area.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';


class SpeechInferencePage extends StatefulWidget {
  final Project project;
  const SpeechInferencePage(this.project, {super.key});

  @override
  State<SpeechInferencePage> createState() => _SpeechInferencePageState();
}

class _SpeechInferencePageState extends State<SpeechInferencePage> with TickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, animationDuration: Duration.zero, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<PreferenceProvider, SpeechInferenceProvider>(
      update: (_, preferences, speechProvider) {
        if (speechProvider == null) {
          return SpeechInferenceProvider(widget.project, preferences.device);
        }
        if (!speechProvider.sameProps(widget.project, preferences.device)) {
          return SpeechInferenceProvider(widget.project, preferences.device);
        }
        return speechProvider;
      },
      create: (_) {
        return SpeechInferenceProvider(widget.project, null);
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
                child: ModelInfo(widget.project),
              ),
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      controller: _tabController,
                      tabs: const [
                        Tab(text: "Video"),
                        Tab(text: "Transcript"),
                      ],
                    ),
                    Expanded(
                      child: Consumer<SpeechInferenceProvider>(
                        builder: (context, inference, child) {
                          return TabBarView(
                            controller: _tabController,
                            children: [
                              VideoPlayerWrapper(inference),
                              TranscriptPage(inference),
                            ],
                          );
                        }
                      ),
                    ),
                  ],
                ),
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
  //String? file;

  //Map<int, FutureOr<String>> transcription = {};

  int subtitleIndex = 0;

  //FutureOr<String> getSegment(int index) async {
  //  final result = widget.inference.transcribe(index * transcriptionPeriod, transcriptionPeriod);

  //  result.then((m) {
  //    setState(() {
  //      transcription[index] = m;
  //    });
  //  });

  //  return result;
  //}

  //void transcribeEntireVideo() async {
  //  int i = 0;
  //  while (true){ // getSegment will throw error at end of file...
  //    if (!context.mounted) {
  //      // Context dropped, so stop this.
  //      break;
  //    }
  //    if (subtitleIndex > i) {
  //      i = subtitleIndex;
  //    }
  //    await getSegment(i);
  //    i++;
  //  }
  //}

  void positionListener(Duration position) {
    int index = (position.inSeconds / transcriptionPeriod).floor();
    widget.inference.skipTo(index);
    if (index != subtitleIndex) {
      setState(() {
          subtitleIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.inference.videoPath != null) {
      initializeVideoAndListeners(widget.inference.videoPath!);
    }
  }

  void initializeVideoAndListeners(String source) async {
    await listener?.cancel();
    player.open(Media(source));
    player.setVolume(0); // TODO: Disable this for release. This is for our sanity
    await widget.inference.loadVideo(source);
    widget.inference.startTranscribing();
    //transcribeEntireVideo();
    listener = player.stream.position.listen(positionListener);
  }

  void loadFile(String path) async {
    await widget.inference.loadVideo(path);
    setState(() {
        subtitleIndex = 0;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const DeviceSelector(),
            //LanguageSelector(inference: widget.inference),
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
          showChild: widget.inference.videoLoaded,
          onUpload: (file) => loadFile(file),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Video(controller: controller),
              Subtitles(transcription: widget.inference.transcription, subtitleIndex: subtitleIndex),
            ]
          ),
        ),
      ],
    );
  }
}

class Subtitles extends StatelessWidget {
  const Subtitles({
    super.key,
    required this.transcription,
    required this.subtitleIndex,
  });

  final Map<int, FutureOr<String>>? transcription;
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
            if (transcription![subtitleIndex] is String) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Text(
                    transcription![subtitleIndex] as String,
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
                    transcription![subtitleIndex] as String,
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

const languages = [
  "",
  "<|en|>",
  "<|nl|>",
];


class LanguageSelector extends StatelessWidget {
  final SpeechInferenceProvider inference;
  const LanguageSelector({super.key, required this.inference});

  @override
  Widget build(BuildContext context) {
      return Row(
        children: [
          const Text("Language: "),
          DropdownButton<String>(
            onChanged: (value) {
              inference.language = value!;
            },
            underline: Container(
                    height: 0,
            ),
            style: const TextStyle(
              fontSize: 12.0,
            ),
            focusColor: intelGrayDark,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            value: inference.language,
            items: languages.map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList()
          ),
        ],
      );
  }
}
