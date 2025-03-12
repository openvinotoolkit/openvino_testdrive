// Copyright (c) 2024 Intel Corporation
//
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

class GetiImport extends StatefulWidget {
  const GetiImport({super.key});

  @override
  State<GetiImport> createState() => _GetiImportState();
}

class _GetiImportState extends State<GetiImport> {
  bool loading = false;
  bool _showReleaseMessage = false;

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
      if (mounted) {
        final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
        projectsProvider.addProject(project);
      }
    }

    if (mounted) {
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

    return Container(
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
    );
  }
}
