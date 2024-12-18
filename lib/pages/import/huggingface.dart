// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/pages/import/providers/import_provider.dart';
import 'package:inference/pages/import/widgets/badge.dart';
import 'package:inference/pages/import/widgets/model_card.dart';
import 'package:inference/widgets/controls/dropdown_multiple_select.dart';
import 'package:inference/widgets/controls/search_bar.dart';
import 'package:inference/widgets/fixed_grid.dart';
import 'package:provider/provider.dart';

class Huggingface extends StatefulWidget {
  const Huggingface({super.key});

  @override
  State<Huggingface> createState() => _HuggingfaceState();
}

class _HuggingfaceState extends State<Huggingface> {
  List<String> selectedOptimizations = [];
  String? searchValue;
  bool orderAsc = true;

  List<Model> filterModels(List<Model> models) {
    var filteredModels = models;
    if (searchValue != null && searchValue!.isNotEmpty) {
      filteredModels = filteredModels.where((model) => model.name.toLowerCase().contains(searchValue!.toLowerCase())).toList();
    }
    if (selectedOptimizations.isNotEmpty) {
      filteredModels = filteredModels.where((model) => selectedOptimizations.contains(model.optimizationPrecision)).toList();
    }

    filteredModels.sort((a,b) => a.name.compareTo(b.name) * (orderAsc ? -1 : 1));
    return filteredModels;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImportProvider>(builder: (context, importProvider, child) {
      return ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1228),
        child: Padding(
          padding: const EdgeInsets.only(left: 133, right: 80, top: 36, bottom: 50),
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
                          child: SearchBar(onChange: (value) { setState(() {
                            searchValue = value;
                          }); }, placeholder: 'Find a model',),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 184),
                          child: DropdownMultipleSelect(
                            items: const ['int4', 'int8', 'fp16'],
                            selectedItems: selectedOptimizations,
                            onChanged: (value) {
                              if (!value.contains(importProvider.selectedModel?.optimizationPrecision)) {
                                importProvider.selectedModel = null;
                              }
                              setState(() {
                                selectedOptimizations = value;
                              });
                            },
                            placeholder: 'Select optimizations',
                          ),
                        ),
                      )
                    ],
                  ),
                  IconButton(icon: Icon(orderAsc ? FluentIcons.descending : FluentIcons.ascending, size: 18,), onPressed: () => setState(() => orderAsc = !orderAsc),),
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
                      children: selectedOptimizations.map((opt) {
                        return Badge(text: opt, onDelete: () {
                          if (opt == importProvider.selectedModel?.optimizationPrecision && selectedOptimizations.length > 1) {
                            importProvider.selectedModel = null;
                          }
                          setState(() {
                            selectedOptimizations.remove(opt);
                          });
                        });
                      }).toList(),
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
                        var allModels = filterModels(snapshot.data!);
                        return FixedGrid(
                          tileWidth: 226,
                          spacing: 24,
                          itemCount: allModels.length,
                          itemBuilder: (context, index) => ModelCard(
                            model: allModels[index],
                            checked: importProvider.selectedModel == allModels[index],
                            onChecked: (value) {
                              setState(() {
                                importProvider.selectedModel = value ? allModels[index] : null;
                              });
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
      );
    });
  }
}
