// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/pages/models/widgets/model_filter.dart';
import 'package:inference/pages/models/widgets/model_list.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/import_model_button.dart';
import 'package:provider/provider.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});

  static Map<String, List<Option>> get filterOptions {
    var options = {
      "Image": [
        const Option("Detection", "detection"),
        const Option("Classification", "classification"),
        const Option("Segmentation", "segmentation"),
        const Option("Anomaly detection","anomaly")
      ],
      "Text Generation": [
        const Option("Text generation", "text"),
      ],
      "Image Generation": [
        const Option("Text to Image", "text-to-image")
      ],
      "Audio": [
        const Option("Speech to text", "speech")
      ]
    };

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ChangeNotifierProvider(
      create: (_) => ProjectFilterProvider(),
      child: ScaffoldPage(
        padding: const EdgeInsets.all(0),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridContainer(
                    color: backgroundColor.of(theme),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Text("My Models",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridContainer(
                      color: backgroundColor.of(theme),
                      padding: const EdgeInsets.all(13),
                      child: ModelFilter(filterOptions: filterOptions)
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  GridContainer(
                    color: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<ProjectFilterProvider>(builder: (context, projectProvider, child) {
                          return Text(projectProvider.option?.name ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                        const ImportModelButton(),
                      ],
                    ),
                  ),
                  const Expanded(child: ModelList()),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
