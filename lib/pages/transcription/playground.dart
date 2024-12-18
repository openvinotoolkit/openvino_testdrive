import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/transcription/utils/media_player_controller.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/pages/transcription/widgets/language_selector.dart';
import 'package:inference/pages/transcription/widgets/subtitles.dart';
import 'package:inference/pages/transcription/widgets/transcription.dart';
import 'package:inference/pages/transcription/utils/message.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/project.dart';
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
  late MediaPlayerController player;
  int subtitleIndex = 0;
  bool showVideo = !Platform.isLinux;

  void showUploadMenu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      uploadFile(result.files.single.path!);
    }
  }

  void onPositionUpdate(Duration position) {
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

  void uploadFile(String file) async {
    final inference = Provider.of<SpeechInferenceProvider>(context, listen: false);
    await inference.loadVideo(file);
    if (showVideo) {
      player.setSource(file);
    }
  }

  @override
  void initState() {
    super.initState();
    player = MediaPlayerController(onPosition: onPositionUpdate);

    if (showVideo) {
      final inference = Provider.of<SpeechInferenceProvider>(context, listen: false);
      if (inference.videoPath != null) {
        player.setSource(inference.videoPath!);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    //Awkward dispose since override doesnt work as expected
    player.dispose().then((_) {
        player.controller?.dispose();
    });
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
                        const LanguageSelector(),
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
                          showChild: inference.videoPath != null,
                          onUpload: (String file) { uploadFile(file); },
                          extensions: const [],
                          child: Builder(
                            builder: (context) {
                              if (!inference.loaded.isCompleted) {
                                return Center(child: Image.asset('images/intel-loading.gif', width: 100));
                              }
                              if (!showVideo) {
                                return GridContainer(
                                  color: backgroundColor.of(theme),
                                  child: Builder(
                                    builder: (context) {
                                      if (inference.transcription == null) {
                                        return Container();
                                      }
                                      return Transcription(
                                        onSeek: player.seek,
                                        transcription: inference.transcription!,
                                        messages: Message.parse(inference.transcription!.data, transcriptionPeriod),
                                      );
                                    }
                                  ),
                                );
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
                                            onSeek: player.seek,
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

