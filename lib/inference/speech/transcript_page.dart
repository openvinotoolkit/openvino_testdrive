import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/providers/speech_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:inference/utils/drop_area.dart';

class TranscriptPage extends StatelessWidget {
  final SpeechInferenceProvider inference;
  const TranscriptPage(this.inference, {super.key});

  void loadFile(String path) async {
    await inference.loadVideo(path);
    inference.startTranscribing();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ),
          ],
        ),
        DropArea(
          type: "video",
          showChild: inference.videoLoaded,
          onUpload: (file) => loadFile(file),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: intelGray,
            ),
            child: Builder(
              builder: (context) {
                if (inference.transcription == null) {
                  return Container();
                }
                String text = inference.transcription!.values.join();
                List<String> sentences = text.split(". ");
                text = sentences.join(".\n");
                //inference.transcription!.values
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SelectableText(text),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}
