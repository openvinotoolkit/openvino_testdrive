// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/project.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/widgets/model_propery.dart';
import 'package:intl/intl.dart';
import 'package:inference/utils.dart';

class ModelProperties extends StatelessWidget {
  final GetiProject project;
  const ModelProperties({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
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
                    value: project.size.readableFileSize(),
                  ),
                  Builder(
                    builder: (context) {
                      if (project.tasks.first.performance == null) {
                        return Container();
                      }
                      return ModelProperty(
                        title: "Accuracy",
                        value: formatter.format(project.tasks.first.performance!.score)
                      );
                    }
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
