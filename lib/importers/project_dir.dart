import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inference/config.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/project.dart';
import 'package:path/path.dart';

class ProjectDirImporter extends Importer {
  final String directory;
  Project? project;

  ProjectDirImporter(this.directory);

  @override
  Future<Project> generateProject() async {
    final projectJson = findProjectJsonFile();
    final source = File(projectJson!).readAsStringSync();
    project =  Project.fromJson(jsonDecode(source), directory);
    return project!;
  }

  String? findProjectJsonFile() {
    final files = Directory(directory).listSync();
    return files.firstWhereOrNull((file) => basename(file.path) == "project.json")?.path;
  }

  @override
  bool match() {
    return findProjectJsonFile() != null;
  }

  @override
  Future<void> setupFiles() async {

    await Config.addModel(project!.storagePath);
    project!.loaded.complete();
    return;
  }

  @override
  Future<bool> askUser(BuildContext context) async {
    return true;
  }
}
