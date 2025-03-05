// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:image/image.dart';
import 'package:archive/archive_io.dart';
import 'package:inference/interop/utils.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/project.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const validTasks = [
  "detection",
  "classification",
  "segmentation",
  "instance_segmentation",
  "rotated_detection",
  "anomaly_detection",
  "anomaly_classification",
  "anomaly_segmentation"
];

final archiveContext =
    Context(style: Style.posix); // ZipDecoder uses posix format
final platformContext = Context(style: Style.platform);

class GetiDeploymentProcessor extends Importer {
  final String zipPath;
  Archive archive;
  GetiProject? project;

  GetiDeploymentProcessor(this.zipPath, this.archive);

  @override
  bool match() {
    final projectJson = archive.findFile("deployment/project.json");
    return projectJson != null;
  }

  @override
  Future<void> setupFiles() async {
    if (project == null) {
      throw Exception("Project is not initialized before processing files");
    }
    final sampleImage = archive.findFile("sample_image.jpg");
    final samplePath = platformContext.join(project!.storagePath, 'sample.jpg');
    final outputStream = OutputFileStream(samplePath);
    sampleImage!.writeContent(outputStream);

    await (Command()
          ..decodeImageFile(samplePath)
          ..copyResize(width: 288 * 2, maintainAspect: true)
          ..writeToFile(
              platformContext.join(project!.storagePath, 'thumbnail.jpg')))
        .execute();

    for (final task in project!.tasks) {
      await processTask(task);
    }
    const encoder = JsonEncoder.withIndent("  ");
    File(platformContext.join(project!.storagePath, "project.json"))
        .writeAsString(encoder.convert(project!.toMap()));
    project!.loaded.complete();
  }

  @override
  Future<Project> generateProject() async {
    final directory = await getApplicationSupportDirectory();

    final projectJson = archive.findFile("deployment/project.json");
    if (projectJson == null) {
      throw const FormatException(
          "Cannot process archive. Missing project.json.");
    }

    final content = jsonDecode(String.fromCharCodes(projectJson.content));

    final folder =
        platformContext.join(directory.path, const Uuid().v4().toString());

    project = GetiProject(
        content['id'],
        const Uuid().v4().toString(),
        "1.0.0",
        content['name'],
        content["creation_time"],
        ProjectType.image,
        folder);
    project!.hasSample = true;
    final RegExp exp = RegExp(r'(.*) (OpenVINO .*)');

    for (final task in content['pipeline']['tasks']) {
      if (validTasks.contains(task['task_type'])) {
        final taskPerformance = content['performance']['task_performances']
            .firstWhere((tasks) => tasks["task_id"] == task["id"]);
        final labels = List<Label>.from(
            task['labels'].map((labelJson) => Label.fromJson(labelJson)));

        final modelJsonFile =
            archive.findFile("deployment/${task['title']}/model.json");
        if (modelJsonFile == null) {
          throw FormatException(
              "Cannot process archive. Missing ${task['title']}/model.json.");
        }
        final modelJson =
            jsonDecode(String.fromCharCodes(modelJsonFile.content));
        final matches = exp.allMatches(modelJson['name']);
        final architecture = matches.first[1] ?? "";
        final optimization = matches.first[2] ?? "";
        project!.tasks.add(Task(
            task['id'],
            task['title'],
            task['task_type'],
            ["${task['id']}.xml"],
            Score(taskPerformance["score"]["value"]),
            labels,
            architecture,
            optimization));
      }
    }
    return project!;
  }

  Future<bool> processTask(Task task) async {
    try {
      final folder = project!.storagePath;
      final modelBinPath = archive.findFile(
          archiveContext.join("deployment", task.name, "model", "model.bin"));
      final modelBin =
          File(platformContext.join(folder, "${task.id}_model.bin"));
      modelBin
        ..createSync(recursive: true)
        ..writeAsBytesSync(modelBinPath!.content as List<int>);

      final modelXmlPath = archive.findFile(
          archiveContext.join("deployment", task.name, "model", "model.xml"));
      final modelXml =
          File(platformContext.join(folder, "${task.id}_model.xml"));
      modelXml
        ..createSync(recursive: true)
        ..writeAsBytesSync(modelXmlPath!.content as List<int>);

      {
        final String modelXmlPath =
            platformContext.join(folder, "${task.id}_model.xml");
        final String serializedModelXmlPath =
            platformContext.join(folder, task.modelPaths[0]);
        await InteropUtils.serialize(modelXmlPath, serializedModelXmlPath);
      }

      modelXml.delete();
      modelBin.delete();
    } on Exception {
      print("Failed to process ${task.name}");
      return false;
    }
    return true;
  }

  @override
  Future<bool> askUser(BuildContext context) async {
    return true;
  }
}
