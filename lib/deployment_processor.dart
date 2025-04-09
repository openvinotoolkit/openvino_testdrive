// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:inference/config.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/migration/migration_manager.dart';
import 'package:inference/project.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

final archiveContext = Context(style: Style.posix); // ZipDecoder uses posix format


Future<String> fontPath() async {
  final directory = await getApplicationSupportDirectory();
  final platformContext = Context(style: Style.platform);
  return platformContext.join(directory.path, "font.ttf");
}

Future<void> ensureFontIsStored() async {
  final file = File(await fontPath());
  if (file.existsSync()) {
    return;
  }
  final data = await rootBundle.load("fonts/intelone-text-regular.ttf");
  List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await file.writeAsBytes(bytes);
}

Future<List<Project>> loadProjectsFromStorage() async {
  final directory = await getApplicationSupportDirectory();
  final manifest = ManifestImporter("assets/manifest.json");
  await manifest.loadManifest();
  final migrationManager = MigrationManager.withMigrations(
    destinationVersion: currentApplicationVersion,
    manifest: manifest.allModels,
  );

  final modelPaths = [
    Config().externalModels,
    directory.listSync().map((m) => m.path),
  ].expand((l) => l);

  return List.from(modelPaths
    .map((projectFolder) {
      if (!Directory(projectFolder).existsSync()) {
        return null;
      }
      final platformContext = Context(style: Style.platform);
      try {
        final projectFile = File(platformContext.join(projectFolder, "project.json"));
        final content = projectFile.readAsStringSync();
        var jsonContent = jsonDecode(content);
        if (migrationManager.eligible((jsonContent))) {
          jsonContent = migrationManager.migrate(jsonContent);
          const encoder = JsonEncoder.withIndent("  ");
          projectFile.writeAsStringSync(encoder.convert(jsonContent));
        }
        final project = Project.fromJson(jsonContent, projectFolder);
        project.loaded.complete();
        return project;
      } catch (exception, stack) {
        print(exception);
        print(stack);
        return null;
      }
    })
    .where((project) => project != null)
  );
}

Future<void> deleteProjectData(Project project) async {
  final projectDirectory = Directory(project.storagePath);
  if (projectDirectory.existsSync()) {
    projectDirectory.deleteSync(recursive: true);
  }
}

Future<void> copyProjectData(Project project, String to) async {
  final from = project.storagePath;
  await Directory(to).create(recursive: true);
  await for (final file in Directory(from).list(recursive: true)) {
    final copyTo = platformContext.join(to, platformContext.relative(file.path, from: from));
    if (file is Directory) {
      await Directory(copyTo).create(recursive: true);
    } else if (file is File) {
      await File(file.path).copy(copyTo);
    } else if (file is Link) {
      await Link(copyTo).create(await file.target(), recursive: true);
    }
  }
}
