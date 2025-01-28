// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/vlm_inference_provider.dart';
import 'package:inference/utils.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/widgets/horizontal_rule.dart';
import 'package:inference/widgets/model_propery.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelProperties extends StatelessWidget {
  const ModelProperties({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VLMInferenceProvider>(builder: (context, inference, child) {
        Locale locale = Localizations.localeOf(context);
        final formatter = NumberFormat.percentPattern(locale.languageCode);

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
                        title: "Task",
                        value: inference.project!.taskName(),
                      ),
                      ModelProperty(
                        title: "Architecture",
                        value: inference.project!.architecture,
                      ),
                      ModelProperty(
                        title: "Size",
                        value: inference.project!.size?.readableFileSize() ?? "",
                      ),
                      Builder(
                        builder: (context) {
                          if (inference.project!.tasks.first.performance == null) {
                            return Container();
                          }
                          return ModelProperty(
                            title: "Accuracy",
                            value: formatter.format(inference.project!.tasks.first.performance!.score)
                          );
                        }
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
                    ],
                  ),
                )
              ],
            )
          ),
        );
      }
    );
  }
}

