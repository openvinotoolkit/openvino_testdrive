// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:archive/archive_io.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

Future<void> extractFiles(String zipPath, String storagePath) async {
  final inputStream = InputFileStream(zipPath);
  final archive = ZipDecoder().decodeBuffer(inputStream);
  Directory(storagePath).createSync();

  extractArchiveToDisk(archive, storagePath);
  return;
}

class ProjectZipImporter extends Importer {
  final String zipPath;
  Project? project;
  late Archive archive;
  ProjectZipImporter(this.zipPath, this.archive);

  @override
  Future<bool> askUser(BuildContext context) {
    final Completer<bool> okay = Completer<bool>();
    if (File(zipPath).lengthSync() < 1e9) {
      //1 GB limit
      okay.complete(true);
      return okay.future;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) => ContentDialog(
                title: const Text('Selected zipfile is too big'),
                content: const Text(
                    'The size is greater than 1 GB. Please extract the zip content before importing.'),
                actions: <Widget>[
                  Button(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ]));

    return okay.future;
  }

  @override
  bool match() {
    final projectPath = archive.findFile("project.json");
    return projectPath != null;
  }

  @override
  Future<Project> generateProject() async {
    final projectPath = archive.findFile("project.json");
    if (projectPath == null) {
      throw const FormatException(
          "Cannot process archive. Missing project.json.");
    }
    final projectJson = jsonDecode(String.fromCharCodes(projectPath.content));

    final directory = await getApplicationSupportDirectory();
    final storagePath =
        platformContext.join(directory.path, const Uuid().v4().toString());

    project = Project.fromJson(projectJson, storagePath);
    return project!;
  }

  @override
  Future<void> setupFiles() async {
    extractFiles(zipPath, project!.storagePath)
        .then((_) => project!.loaded.complete());
  }
}
