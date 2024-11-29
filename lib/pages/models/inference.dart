import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/computer_vision.dart';
import 'package:inference/pages/text_to_image/text_to_image_page.dart';
import 'package:inference/pages/transcription/transcription.dart';
import 'package:inference/project.dart';

class InferencePage extends StatelessWidget {
  final Project project;
  const InferencePage(this.project, {super.key});

  @override
  Widget build(BuildContext context) {
    switch(project.type){
      case ProjectType.image:
        return ComputerVisionPage(project);
      case ProjectType.text:
        return Container();
      case ProjectType.speech:
        return TranscriptionPage(project);
      case ProjectType.textToImage:
        return TextToImagePage(project);
    }
  }

}
