// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';

void showImportGetiModelDialog(BuildContext context, { required Function(List<Project>?) callback}) async {
  final output = await showDialog<List<Project>>(
    context: context,
    builder: (context) => const ImportGetiModelDialog(),
  );

  callback(output);
}

class ImportGetiModelDialog extends StatefulWidget {
  const ImportGetiModelDialog({super.key});

  @override
  State<ImportGetiModelDialog> createState() => _ImportGetiModelDialogState();
}

class _ImportGetiModelDialogState extends State<ImportGetiModelDialog> {
  bool _showReleaseMessage = false;
  bool loading = false;

  void selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ["zip"]);
    if (result != null) {
      processFiles(result.files.map((p) => p.path!).toList());
    } else {
      // User canceled the picker
    }
  }

  Future<void> processFiles(List<String> paths) async {
    setState(() => loading = true);

    List<Project> projects = [];
    for (final file in paths) {
      final importer = selectMatchingImporter(file);
      if (importer == null) {
        print("unable to process file");
        return;
      }
      final project = await importer.generateProject();
      await importer.setupFiles();
      projects.add(project);
      await project.loaded.future;
      if (context.mounted) {
        final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
        projectsProvider.addProject(project);
      }
    }

    if (context.mounted) {
      Navigator.pop(context, projects);
    }
  }

  void showReleaseMessage() {
    setState(() => _showReleaseMessage = true);
  }

  void hideReleaseMessage() {
    setState(() => _showReleaseMessage = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

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
            child: Container(
              color: backgroundColor.of(theme),
              child: Builder(
                builder: (context) {
                  if (loading) {
                    return Center(child: Image.asset('images/intel-loading.gif', width: 100));
                  }
                  final String text = _showReleaseMessage
                    ? "Release to import models"
                    : "Drag and drop Intel Geti models";

                  return DropTarget(
                    onDragDone: (details) {
                      processFiles(details.files.map((f) => f.path).toList());
                    },
                    onDragExited: (val) => hideReleaseMessage(),
                    onDragEntered: (val) => showReleaseMessage(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(text,
                          style: const TextStyle(
                            fontSize: 28,
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: SvgPicture.asset('images/drop_geti.svg'),
                        ),
                        const Text("Currently, we only support"),
                        const Text("models exported from Intel Geti"),
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: FilledButton(
                            onPressed: () => selectFile(),
                            child: const Text("Select file(s)"),
                          ),
                        )
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
