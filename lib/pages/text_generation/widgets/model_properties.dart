// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/widgets/horizontal_rule.dart';
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
                      title: "Temperature: ${nf.format(inference.temperature)}",
                      description: "Temperature controls the randomness of the output. Higher values mean more random outputs.",
                      child: Slider(
                        value: inference.temperature,
                        onChanged: (value) { inference.temperature = value; },
                        label: nf.format(inference.temperature),
                        max: 1.0,
                        min: 0.1,
                      ),
                    ),
                    ModelProperty(
                      title: "Top P: ${nf.format(inference.topP)}",
                      description: "Top P controls the diversity of the output by limiting the selection to a subset of the most probable tokens.",
                      child: Slider(
                        value: inference.topP,
                        onChanged: (value) { inference.topP = value; },
                        label: nf.format(inference.topP),
                        max: 2.0,
                        min: 0.1,
                      ),
                    ),
                    if (inference.project!.isPublic) Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HorizontalRule(),
                        const Text('External links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        HyperlinkButton(
                          child: const Text("Model on Hugging Face"), onPressed: () { launchUrl(Uri.parse('https://huggingface.co/${inference.project!.modelId}')); }
                        ),
                      ],
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
