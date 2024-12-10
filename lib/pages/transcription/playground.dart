import 'dart:async';

import 'package:av_media_player/player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/pages/transcription/utils/av_player.dart';
import 'package:inference/pages/transcription/widgets/subtitles.dart';
import 'package:av_media_player/widget.dart';
import 'package:inference/pages/transcription/widgets/transcription.dart';
import 'package:inference/pages/transcription/utils/message.dart';
import 'package:inference/project.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/controls/drop_area.dart';
import 'package:inference/widgets/controls/no_outline_button.dart';
import 'package:inference/widgets/device_selector.dart';
import 'package:provider/provider.dart';
import 'package:universal_video_controls/universal_video_controls.dart';

class Playground extends StatefulWidget {
  final Project project;
  const Playground({super.key, required this.project});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> with TickerProviderStateMixin{
  int subtitleIndex = 0;
  StreamSubscription<Duration>? listener;
  late AVPlayer player;


  void showUploadMenu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      uploadFile(result.files.single.path!);
    }
  }

  void positionListener(Duration position) {
    int index = (position.inSeconds / transcriptionPeriod).floor();
    if (index != subtitleIndex) {
      final inference = Provider.of<SpeechInferenceProvider>(context, listen: false);
      inference.skipTo(index);
      setState(() {
          subtitleIndex = index;
      });
    }
  }

  void initializeVideoAndListeners(String source) {

    player.setSource(source);
    //await listener?.cancel();
    //player = AvMediaPlayer(
      //initSource: widget.initSource,
      //initAutoPlay: widget.initAutoPlay,
      //initLooping: widget.initLooping,
      //initVolume: widget.initVolume,
      //initSpeed: widget.initSpeed,
      //initPosition: widget.initPosition,
      //initShowSubtitle: widget.initShowSubtitle,
      //initPreferredSubtitleLanguage: widget.initPreferredSubtitleLanguage,
      //initPreferredAudioLanguage: widget.initPreferredAudioLanguage,
      //initMaxBitRate: widget.initMaxBitRate,
      //initMaxResolution: widget.initMaxResolution,
    //);

    //player.

    //await player.open(Media(source));
    //await player.setVolume(0); // TODO: Disable this for release. This is for our sanity
    //listener = player.stream.position.listen(positionListener);
  }

  void uploadFile(String file) async {
    //final inference = Provider.of<SpeechInferenceProvider>(context, listen: false);
    //await inference.loadVideo(file);
    initializeVideoAndListeners(file);
  }

  @override
  void initState() {
    super.initState();
    player = AVPlayer(AvMediaPlayer());
    final inference = Provider.of<SpeechInferenceProvider>(context, listen: false);
    if (inference.videoPath != null) {
      initializeVideoAndListeners(inference.videoPath!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: GridContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        NoOutlineButton(
                          onPressed: showUploadMenu,
                          child: Row(
                            children: [
                              const Text("Choose video"),
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(FluentIcons.chevron_down, size: 12),
                              ),
                            ],
                          ),
                        ),
                        const DeviceSelector(),
                      ],
                    ),
                  ),
                ),
              ),
              Consumer<SpeechInferenceProvider>(
                builder: (context, inference, child) {
                  return Expanded(
                    child: Builder(
                      builder: (context) {
                        return DropArea(
                          type: "video",
                          showChild: true, //inference.videoPath != null,
                          onUpload: (String file) { uploadFile(file); },
                          extensions: const [],
                          child: Builder(
                            builder: (context) {
                              if (!inference.loaded.isCompleted) {
                                return Center(child: Image.asset('images/intel-loading.gif', width: 100));
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: GridContainer(
                                      color: backgroundColor.of(theme),
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          VideoControls(
                                            player: player,
                                          ),
                                          //Center(
                                          //  child: AvMediaView(
                                          //    initPlayer: ,
                                          //    initSource: inference.videoPath,
                                          //    initLooping: true,
                                          //    initAutoPlay: true,
                                          //    onCreated: (player) {
                                          //      player.loading.addListener(
                                          //        () => print("loaded")
                                          //      );
                                          //    }
                                          //  ),
                                          //),
                                          Subtitles(
                                            transcription: inference.transcription?.data,
                                            subtitleIndex: subtitleIndex,
                                          ),
                                        ]
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 360,
                                    child: GridContainer(
                                      color: backgroundColor.of(theme),
                                      child: Builder(
                                        builder: (context) {
                                          if (inference.transcription == null) {
                                            return Container();
                                          }
                                          return Transcription(
                                            onSeek: (_) {},
                                            transcription: inference.transcription!,
                                            messages: Message.parse(inference.transcription!.data, transcriptionPeriod),
                                          );
                                        }
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }
                          ),
                        );
                      }
                    ),
                  );
                }
              )
            ],
          ),
        ),
        ModelProperties(project: widget.project),
      ]
    );
  }
}

