// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/importers/model_directory_importer.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';

class DirectoryImport extends StatefulWidget {
  const DirectoryImport({super.key});

  @override
  State<DirectoryImport> createState() => _DirectoryImportState();
}

class _DirectoryImportState extends State<DirectoryImport> {
  bool _showReleaseMessage = false;

  void showReleaseMessage() {
    setState(() => _showReleaseMessage = true);
  }

  void hideReleaseMessage() {
    setState(() => _showReleaseMessage = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    Future<void> selectFolder() async {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        print(result);
        final importer = ModelDirImporter(result);
        final project = await importer.generateProject();
        importer.setupFiles();
        if (context.mounted) {
          final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
          projectsProvider.addProject(project);
          Navigator.pop(context, [project]);
        }
        //processFiles(result.files.map((p) => p.path!).toList());
      } else {
        // User canceled the picker
      }
    }

    return Container(
      color: backgroundColor.of(theme),
      child: Builder(
        builder: (context) {
          final String text = _showReleaseMessage
            ? "Release to import model"
            : "Drag and drop a directory with a model";


          return DropTarget(
            onDragDone: (details) {
              //processFiles(details.files.map((f) => f.path).toList());
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
                    onPressed: () => selectFolder(),
                    child: const Text("Select folder"),
                  ),
                )
              ],
            ),
          );
        }
      )
    );
  }
}
