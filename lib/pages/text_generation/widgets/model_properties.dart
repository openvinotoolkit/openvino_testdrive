import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/widgets/model_propery.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelProperties extends StatelessWidget {
  const ModelProperties({super.key});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
      locale: locale.languageCode, decimalDigits: 2);

    return Consumer<TextInferenceProvider>(builder: (context, inference, child) {
      return SizedBox(
        width: 280,
        child: GridContainer(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Model parameters", style: TextStyle(
                  fontSize: 20,
              )),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModelProperty(
                      title: "Model name",
                      value: inference.project!.name,
                    ),
                    ModelProperty(
                      title: "Architecture",
                      value: inference.project!.architecture,
                    ),
                    ModelProperty(
                      title: "Temperature",
                      description: "Temperature controls the randomness of the output. Higher values mean more random outputs.",
                      value: nf.format(inference.temperature),
                    ),
                    ModelProperty(
                      title: "Top P",
                      description: "Top P controls the diversity of the output by limiting the selection to a subset of the most probable tokens.",
                      value: nf.format(inference.topP),
                    ),
                    if (inference.project!.isPublic) HyperlinkButton(
                      child: const Row(children: [
                        Text("View on Hugging Face"),
                        SizedBox(width: 4),
                        Icon(FluentIcons.pop_expand),
                      ],), onPressed: () { launchUrl(Uri.parse('https://huggingface.co/${inference.project!.modelId}')); }
                    ),
                  ]
                )
              ),
            ]
          )
        )
      );
  });
  }
}