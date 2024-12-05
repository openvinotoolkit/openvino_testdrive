import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  final englishToken = "<|en|>";

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechInferenceProvider>(builder: (context, provider, child) {
        return ToggleSwitch(
          checked: provider.language == englishToken,
          onChanged: (value) async {
            provider.language = value ? englishToken : "";
          },
          content: const Text("Translate to english"),
        );
      }
    );
  }
}
