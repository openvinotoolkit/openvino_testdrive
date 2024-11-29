import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:inference/project.dart';
import 'package:inference/public_model_info.dart';
import 'package:inference/utils/get_public_thumbnail.dart';
import 'package:inference/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Model {
  final String name;
  final String id;
  final int fileSize;
  final String optimizationPrecision;
  final int contextWindow;
  final String description;
  final String task;

  Model({
    required this.name,
    required this.id,
    required this.fileSize,
    required this.optimizationPrecision,
    required this.contextWindow,
    required this.description,
    required this.task,
  });

  Image get thumbnail {
    return getThumbnail(id);
  }

  String get kind => task == 'text-generation' ? 'llm' : 'other';

  String get readableFileSize {
    return fileSize.toDouble().readableFileSize();
  }

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      name: json['name'],
      id: json['id'],
      fileSize: json['fileSize'],
      optimizationPrecision: json['optimizationPrecision'],
      contextWindow: json['contextWindow'],
      description: json['description'],
      task: json['task'],
    );
  }

  Future<Project> convertToProject() async {
    final directory = await getApplicationSupportDirectory();
    final projectId = const Uuid().v4();
    final storagePath = platformContext.join(directory.path, projectId.toString());
    await Directory(storagePath).create(recursive: true);
    final projectType = parseProjectType(task);

    final project = PublicProject(
      projectId,
      "OpenVINO/$id",
      "1.0.0",
      name,
      DateTime.now().toIso8601String(),
      projectType,
      storagePath,
      thumbnail,
      PublicModelInfo(
        id,
        DateTime.now().toIso8601String(),
        0,
        0,
        task,
        const Collection("https://huggingface.co/api/collections/OpenVINO/llm-6687aaa2abca3bbcec71a9bd", "", "text"),
      ),
    );

    project.tasks.add(
      Task(
        genUUID(),
        task,
        task,
        [],
        null,
        [],
        "",
        "",
      ),
    );

    return project;
  }
}

class ManifestImporter {
  final String manifestPath;
  List<Model> popularModels = [];
  List<Model> allModels = [];

  ManifestImporter(this.manifestPath);

  Future<void> loadManifest() async {
    final contents = await rootBundle.loadString(manifestPath);
    final jsonData = jsonDecode(contents);

    popularModels = (jsonData['popular_models'] as List)
        .map((modelJson) => Model.fromJson(modelJson))
        .toList();

    allModels = (jsonData['all_models'] as List)
        .map((modelJson) => Model.fromJson(modelJson))
        .toList();
  }

  List<Model> getPopularModels() {
    return popularModels;
  }

  List<Model> getAllModels() {
    return allModels;
  }
}
