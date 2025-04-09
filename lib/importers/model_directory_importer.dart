// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inference/config.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/migration/migration_manager.dart';
import 'package:inference/project.dart';
import 'package:path/path.dart';

class ModelDirImporter extends Importer {
  final String directory;
  Project? project;

  ModelDirImporter(this.directory);

  @override
  Future<Project> generateProject() async {
    final projectJson = findProjectJsonFile();
    if (projectJson == null) {
      throw Exception("no project json in file");
    } else {
      final migrationManager = MigrationManager.withMigrations(
        destinationVersion: currentApplicationVersion,
        manifest: [],
      );

      final source = File(projectJson).readAsStringSync();
      final migrated = migrationManager.migrate(jsonDecode(source));
      project =  Project.fromJson(migrated, directory);
    }
    return project!;
  }

  bool get containsProjectJson => findProjectJsonFile() != null;

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

    await Config().addExternalModel(project!.storagePath);
    project!.loaded.complete();
    return;
  }

  @override
  Future<bool> askUser(BuildContext context) async {
    return true;
  }
}
