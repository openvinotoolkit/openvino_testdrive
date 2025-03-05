// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/project.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/widgets/horizontal_rule.dart';
import 'package:inference/widgets/model_propery.dart';
import 'package:inference/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelProperties extends StatelessWidget {
  final Project project;
  const ModelProperties({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
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
                    value: project.name,
                  ),
                  ModelProperty(
                    title: "Task",
                    value: project.taskName(),
                  ),
                  ModelProperty(
                    title: "Architecture",
                    value: project.architecture,
                  ),
                  ModelProperty(
                    title: "Size",
                    value: project.size?.readableFileSize() ?? "",
                  ),
                  if (project is PublicProject) Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HorizontalRule(),
                      const Text('External links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      HyperlinkButton(
                          child: const Text("Model on Hugging Face"), onPressed: () { launchUrl(Uri.parse('https://huggingface.co/${project.modelId}')); }
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
}
