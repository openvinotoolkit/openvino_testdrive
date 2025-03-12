// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/import/widgets/directory_import.dart';
import 'package:inference/pages/import/widgets/geti_import.dart';
import 'package:inference/project.dart';

void showImportModelDialog(BuildContext context, { required Function(List<Project>?) callback}) async {
  final output = await showDialog<List<Project>>(
    context: context,
    builder: (context) => const ImportModelDialog(),
  );

  callback(output);
}

class ImportModelDialog extends StatefulWidget {
  const ImportModelDialog({super.key});

  @override
  State<ImportModelDialog> createState() => _ImportModelDialogState();
}

class _ImportModelDialogState extends State<ImportModelDialog> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final updatedTheme = theme.copyWith(
        navigationPaneTheme: theme.navigationPaneTheme.merge(NavigationPaneThemeData(
            backgroundColor: theme.scaffoldBackgroundColor,
        ))
    );

    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 688,
        maxHeight: 580,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Import model from your local disk'),
                IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: () { Navigator.pop(context, List<Project>.from([])); },
                )
              ],
            ),
          ),
          Expanded(
            child: FluentTheme(
              data: updatedTheme,
              child: NavigationView(
                pane: NavigationPane(
                  selected: selected,
                  onChanged: (i) => setState(() {selected = i;}),
                  displayMode: PaneDisplayMode.top,
                    items: [
                      PaneItem(
                        icon: Icon(FluentIcons.car),
                        title: const Text("Geti"),
                        body: GetiImport(),
                      ),
                      PaneItem(
                        icon: Icon(FluentIcons.car),
                        title: const Text("Directory"),
                        body: DirectoryImport(),
                      ),
                    ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
