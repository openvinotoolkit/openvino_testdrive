// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/importers/model_directory_importer.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:path/path.dart' show dirname;
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

  Future<void> selectFolder() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      processFolder(directory);
    } else {
      // User canceled the picker
    }
  }

  Future<void> processFolder(String directory) async {
    final importer = ModelDirImporter(directory);
    final project = await importer.generateProject();
    importer.setupFiles();
    if (mounted) {
      final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
      projectsProvider.addProject(project);
      Navigator.pop(context, [project]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      color: backgroundColor.of(theme),
      child: Builder(
        builder: (context) {
          final String text = _showReleaseMessage
            ? "Release to import model"
            : "Drag and drop a directory with a model";


          return DropTarget(
            onDragDone: (details) {
              if (details.files.isNotEmpty) {
                final target = details.files.first.path;
                if (Directory(target).existsSync()) {
                  processFolder(target);
                } else {
                  processFolder(dirname(target));
                }
              }
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
