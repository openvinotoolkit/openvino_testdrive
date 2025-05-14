// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/importers/model_directory_importer.dart';
import 'package:inference/importers/model_manifest.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/utils.dart';
import 'package:path/path.dart' show dirname;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class DirectoryImport extends StatefulWidget {
  const DirectoryImport({super.key});

  @override
  State<DirectoryImport> createState() => _DirectoryImportState();
}

class _DirectoryImportState extends State<DirectoryImport> {
  bool _showReleaseMessage = false;
  String? selectedFolder;

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
    if (importer.containsProjectJson) {
      final project = await importer.generateProject();
      importer.setupFiles();
      if (mounted) {
        final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
        projectsProvider.addProject(project);
        Navigator.pop(context, [project]);
      }
    } else {
      setState(() {
        selectedFolder = directory;
      });
    }
  }

  Future<void> importProject(Project project) async {
    final importer = ModelDirImporter(project.storagePath);
    importer.project = project;
    writeProjectJson(project);
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
            child: Builder(
              builder: (context) {
                if (selectedFolder != null && !_showReleaseMessage) {
                  return ModelImportPropertiesForm(
                    storagePath: selectedFolder!,
                    onProjectImport: importProject,
                    onCancel: () {
                      setState(() => selectedFolder = null);
                    },
                  );
                }
                return Column(
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
                );
              }
            ),
          );
        }
      )
    );
  }
}

class ModelImportPropertiesForm extends StatefulWidget {
  final String storagePath;
  final Function? onCancel;
  final Function(Project)? onProjectImport;
  const ModelImportPropertiesForm({
    super.key,
    required this.storagePath,
    this.onProjectImport,
    this.onCancel,
  });

  @override
  State<ModelImportPropertiesForm> createState() => _ModelImportPropertiesFormState();
}

class _ModelImportPropertiesFormState extends State<ModelImportPropertiesForm> {
  ProjectType projectType = ProjectType.text;
  final TextEditingController _controller = TextEditingController();

  void generateModelManifest() async {
    final name = _controller.text;
    final manifest = ModelManifest(
      name: name,
      id: const Uuid().v4().toString(),
      fileSize: calculateDiskUsage(widget.storagePath),
      task: projectTypeToString(projectType),
      author: "Unknown",
      collection: "",
      description: "Try out $name",
      npuEnabled: true,
      contextWindow: 0,
      optimizationPrecision: "",
    );

    widget.onProjectImport?.call(await PublicProject.fromModelManifest(manifest, widget.storagePath));
  }

  bool get validForm => _controller.text.isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                InfoLabel(
                  label: "Model name",
                  child: TextBox(
                    placeholder:  "Name",
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                  )
                ),
                const SizedBox(height: 10),
                InfoLabel(
                  label: "Task",
                  child: ComboBox<ProjectType>(
                    value: projectType,
                    items: List<ComboBoxItem<ProjectType>>.from([
                        ProjectType.text,
                        ProjectType.vlm,
                        ProjectType.textToImage,
                        ProjectType.speech,
                      ].map((t) {
                      return ComboBoxItem<ProjectType>(
                        value: t,
                        child: Text(projectTypeToName(t)),
                      );
                    })),
                    placeholder: const Text("Select model task"),
                    onChanged: (t) => setState(() => projectType = t!),
                  )
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Button(
                onPressed: () => widget.onCancel?.call(),
                child: const Text("Cancel"),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: validForm ? () => generateModelManifest() : null,
                child: const Text("Import"),
              ),
            ],
          )

        ],
      ),
    );
  }
}
