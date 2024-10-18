import 'package:flutter/material.dart';
import 'package:inference/inference/download_page.dart';
import 'package:inference/inference/image_inference_page.dart';
import 'package:inference/inference/speech/speech_inference_page.dart';
import 'package:inference/inference/text_inference_page.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:provider/provider.dart';

class InferencePage extends StatefulWidget {
  final Project project;
  const InferencePage(this.project, {super.key});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.project.isDownloaded) {
      switch(widget.project.type){
        case ProjectType.image:
          return ImageInferencePage(widget.project);
        case ProjectType.text:
          return TextInferencePage(widget.project);
        case ProjectType.speech:
          return SpeechInferencePage(widget.project);
      }
    } else {
      return ChangeNotifierProvider<DownloadProvider>(
          create: (_) => DownloadProvider(widget.project),
          child:  DownloadPage(widget.project as PublicProject,
            onDone: () => setState(() {}), //trigger rerender.
          )
      );
    }
  }
}
