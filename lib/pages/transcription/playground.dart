import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/project.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/utils/drop_area.dart';
import 'package:inference/widgets/controls/no_outline_button.dart';
import 'package:inference/widgets/device_selector.dart';
//import 'package:media_kit/media_kit.dart';
//import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

class Playground extends StatefulWidget {
  final Project project;
  const Playground({super.key, required this.project});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  //late final player = Player();
  //late final controller = VideoController(player);

  void showUploadMenu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      uploadFile(result.files.single.path!);
    }
  }

  void uploadFile(String file) async {
    final inference = Provider.of<SpeechInferenceProvider>(context, listen: false);
    await inference.loadVideo(file);
    inference.startTranscribing();
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
              Expanded(
                child: GridContainer(
                  color: backgroundColor.of(theme),
                  child: Builder(
                    builder: (context) {
                      return DropArea(
                        type: "video",
                        showChild: false,
                        onUpload: (String file) { uploadFile(file); },
                        extensions: const [],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(),
                        ),
                      );
                    }
                  ),
                ),
              )
            ],
          ),
        ),
        ModelProperties(project: widget.project),
      ]
    );
  }
}
