// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/pages/import/providers/import_provider.dart';
import 'package:inference/pages/import/widgets/badge.dart';
import 'package:inference/pages/import/widgets/model_card.dart';
import 'package:inference/pages/models/widgets/model_filter.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/controls/dropdown_multiple_select.dart';
import 'package:inference/widgets/controls/search_bar.dart';
import 'package:inference/widgets/empty_model_widget.dart';
import 'package:inference/widgets/fixed_grid.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:provider/provider.dart';

class Huggingface extends StatelessWidget {
  const Huggingface({super.key});

  static Map<String, List<Option>> get filterOptions {
    var options = {
      "Text Generation": [
        const Option("Text generation", "text-generation"),
      ],
      "Image Generation": [
        const Option("Text to Image", "text-to-image")
      ],
      "Visual language models": [
        const Option("Image to text", "image-text-to-text")
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

    return Consumer<ImportProvider>(builder: (context, importProvider, child) {
      return Consumer<ProjectFilterProvider>(
        builder: (context, filter, child) {
          return ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1228),
            child: Row(
              children: [
                GridContainer(
                  color: backgroundColor.of(theme),
                  padding: const EdgeInsets.all(13),
                  child: ModelFilter(filterOptions: filterOptions)
                ),
                Expanded(
                  child: GridContainer(
                    color: backgroundColor.of(theme),
                    padding: const EdgeInsets.only(left: 33, right: 80, top: 36, bottom: 50),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 280),
                                  child: Semantics(
                                    label: 'Find a model',
                                    child: SearchBar(
                                      placeholder: 'Find a model',
                                      onChange: (value) {
                                        filter.name = value;
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 184),
                                    child: DropdownMultipleSelect(
                                      items: const ['int4', 'int8', 'fp16'],
                                      selectedItems: filter.optimizations,
                                      onChanged: (value) {
                                        filter.optimizations = value;
                                      },
                                      placeholder: 'Select optimizations',
                                    ),
                                  ),
                                )
                              ],
                            ),
                            IconButton(icon: Icon(filter.order ? FluentIcons.descending : FluentIcons.ascending, size: 18,), onPressed: () => filter.order = !filter.order),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                          child: SizedBox(
                            height: 28,
                            width: double.infinity,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  ...filter.optimizations.map((opt) {
                                    return Badge(text: opt, onDelete: () {
                                      if (opt == importProvider.selectedModel?.optimizationPrecision && filter.optimizations.length > 1) {
                                        importProvider.selectedModel = null;
                                      }
                                      filter.removeOptimization(opt);
                                    });
                                  }),
                                  if (filter.option != null)
                                    Badge(text: filter.option!.name, onDelete: () {
                                        filter.option = null;
                                    })
                                ]
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: FutureBuilder<List<Model>>(
                              future: importProvider.allModelsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const ProgressRing();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Text('No models available');
                                } else {
                                  var allModels = filter.applyFilterOnModel(snapshot.data!);
                                  return FixedGrid(
                                    tileWidth: 226,
                                    spacing: 24,
                                    itemCount: allModels.length,
                                    emptyWidget: EmptyModelListWidget(searchQuery: filter.name),
                                    itemBuilder: (context, index) => ModelCard(
                                      model: allModels[index],
                                      checked: importProvider.selectedModel == allModels[index],
                                      onChecked: (value) {
                                        importProvider.selectedModel = value ? allModels[index] : null;
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      );
    });
  }
}
