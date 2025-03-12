// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/model_manifest.dart';
import 'package:inference/utils/get_public_thumbnail.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
String genUUID() => uuid.v4().toString();
final platformContext = Context(style: Style.platform);

const currentApplicationVersion = "25.0.1";

class Score {
  double score = 0.0;

  Score(this.score);

  Object toMap() {
    return score;
  }
}

class Label {
  String id;
  String name;
  String color;
  bool isEmpty;

  Label(this.id, this.name, this.color, this.isEmpty);

  static Label fromJson(json) {
    return Label(
      json["id"],
      json["name"],
      json["color"],
      json["is_empty"]
    );
  }

  Object toMap() {
    return {
        "id": id,
        "name": name,
        "color": color,
        "is_empty": isEmpty
    };
  }
}

class Task {
  String id;
  String name;
  String taskType;
  List<String> modelPaths;
  Score? performance;
  List<Label> labels;
  String architecture;
  String optimization;

  Task(this.id, this.name, this.taskType, this.modelPaths, this.performance, this.labels, this.architecture, this.optimization);

  String calculatorName() {
    switch(taskType) {
      case "rotated_detection":
        return "RotatedDetection";
      case "anomaly_classification":
      case "anomaly_detection":
      case "anomaly_segmentation":
        return "Anomaly";
      case "instance_segmentation":
        return "InstanceSegmentation";
      default:
        final name = taskType.replaceAll(" ", "");
        return "${name[0].toUpperCase()}${name.substring(1)}";
    }
  }

  Object toMap() {
    return {
        "id": id,
        "name": name,
        "task_type": taskType,
        "model_paths": modelPaths,
        "performance": performance?.toMap(),
        "labels": labels.map((label) => label.toMap()).toList(),
        "architecture": architecture,
        "optimization": optimization,
    };
  }

  static Task fromJson(json) {
    return Task(
      json["id"],
      json["name"],
      json["task_type"],
      List<String>.from(json["model_paths"]),
      (json["performance"] == null ? null : Score(json["performance"])),
      List<Label>.from(json["labels"].map((labelJson) => Label.fromJson(labelJson))),
      json["architecture"],
      json["optimization"]
    );
  }
}

enum ProjectType { image, text, textToImage, speech, vlm }
ProjectType parseProjectType(String name) {
  if (name == "image") {
    return ProjectType.image;
  }
  if (name == "text" || name == "text-generation"){
    return ProjectType.text;
  }
  if (name == "textToImage" || name == "text-to-image"){
    return ProjectType.textToImage;
  }
  if (name == "vlm" || name == "image-text-to-text"){
    return ProjectType.vlm;
  }
  if (name == "speech") {
    return ProjectType.speech;
  }

  throw UnimplementedError(name);
}

String projectTypeToString(ProjectType type) {
  switch(type){
    case ProjectType.text:
      return "text";
    case ProjectType.textToImage:
      return "textToImage";
    case ProjectType.vlm:
      return "vlm";
    case ProjectType.image:
      return "image";
    case ProjectType.speech:
      return "speech";
  }
}

class Project {
  String id;
  String modelId;
  String applicationVersion;
  String name;
  String creationTime;
  ProjectType type;
  String storagePath;
  Completer<void> loaded = Completer<void>();
  bool isPublic;
  bool hasSample = false;

  String get architecture {
    //if (tasks.length > 1) {
    //  return "Task Chain";
    //}
    //return tasks.first.architecture;
    return "";
  }

  bool get npuSupported {
    return false;
  }

  String taskName() {
    return "";
  }

  Future<bool> isInAppStorage() async {
    final directory = await getApplicationSupportDirectory();
    return storagePath.contains(directory.path);
  }

  bool get isDownloaded => true;

  Project(this.id, this.modelId, this.applicationVersion, this.name, this.creationTime, this.type, this.storagePath, this.isPublic);

  int get size => 0;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "model_id": modelId,
      "name": name,
      "creation_time": creationTime,
      "type": projectTypeToString(type),
      "application_version": applicationVersion,
      "is_public": isPublic,
    };
  }

  ImageProvider thumbnailImage() {
    throw Error();
  }

  static Project fromJson(Map<String, dynamic> json, String storagePath) {
    return switch(json){
      {'is_public': true} => PublicProject.fromJson(json, storagePath),
      _ => GetiProject.fromJson(json, storagePath),
    };
  }
}

class GetiProject extends Project {
  List<Task> tasks = [];
  @override
  late int size;

  GetiProject(String id, String modelId, String applicationVersion, String name, String creationTime, ProjectType type, String storagePath)
    : super(id, modelId, applicationVersion, name, creationTime, type, storagePath, false) {
    size = calculateDiskUsage();
  }

  int calculateDiskUsage() {
    final dir = Directory(storagePath);
    if (dir.existsSync()) {
      return dir.listSync(recursive: true).fold(0, (acc, m) => acc + m.statSync().size);
    }
    return 0;
  }

  List<Score?> scores() {
    return tasks.map((t) => t.performance).toList();
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map["geti"] = tasks.map((t) => t.toMap()).toList();
    return map;
  }

  @override
  String taskName() {
    if (tasks.length > 1) {
      return "Task Chain";
    }
    return tasks.first.name;
  }

  @override
  ImageProvider thumbnailImage() {
    final path = platformContext.join(storagePath, "thumbnail.jpg");
    final imageFile = File(path);
    if (imageFile.existsSync()){
      return FileImage(imageFile);
    } else {
      return const AssetImage('images/intel-loading.gif');
    }
  }

  List<Label> labels() {
    return tasks.map((t) => t.labels).expand((i) => i).where((label) => !label.isEmpty).toList();
  }

  String samplePath() {
    return platformContext.join(storagePath, "sample.jpg");
  }


  @override
  String get architecture {
    if (tasks.length > 1) {
      return "Task Chain";
    }
    return tasks.first.architecture;
  }

  List<Label> get labelDefinitions {
    return tasks.map((t) => t.labels).flattened.toList();
  }

  static GetiProject fromJson(json, String storagePath) {
    if (json["application_version"] != currentApplicationVersion) {
      throw const FormatException("Project is for different version");
    }
    var project = GetiProject(
      json["id"],
      json["model_id"],
      json["application_version"],
      json["name"],
      json["creation_time"],
      parseProjectType(json["type"]),
      storagePath
    );
    project.hasSample = json["has_sample"] != null && json["has_sample"];
    project.tasks = List.from(json["geti"].map((task) => Task.fromJson(task)));
    return project;
  }

  @override
  bool operator ==(other) {
    if (other is! Project){
      return false;
    }

    if (other.id != id) {
      return false;
    }

    return const ListEquality().equals(
      (other as GetiProject).tasks.map((m) => m.id).toList(),
      tasks.map((m) => m.id).toList()
    );
  }

  @override
  int get hashCode{
    return Object.hash(
      id,
      const ListEquality().hash(tasks.map((m) => m.id).toList()),
    );
  }
}

class PublicProject extends Project {
  @override
  // ignore: overridden_fields
  Completer<void> loaded = Completer<void>();
  ModelManifest manifest;

  PublicProject(String id, String modelId, String applicationVersion, String name, String creationTime, ProjectType type, String storagePath, this.manifest)
    : super(id, modelId, applicationVersion, name, creationTime, type, storagePath, true);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map["manifest"] = manifest.toJson();
    return map;
  }

  @override
  int get size => manifest.fileSize;

  @override
  bool get npuSupported {
    return manifest.npuEnabled;
  }

  Image get thumbnail {
    return getThumbnail(modelId);
  }

  @override
  String get architecture {
    return manifest.architecture ?? "unknown";
  }

  @override
  String taskName() {
    return projectTypeToString(type);
  }

  @override
  ImageProvider thumbnailImage() {
    return thumbnail.image;
  }

  @override
  bool get isDownloaded => loaded.isCompleted;

  static Future<PublicProject> fromModelManifest(ModelManifest manifest) async {
    final directory = await getApplicationSupportDirectory();
    final projectId = manifest.id;
    final storagePath = platformContext.join(directory.path, projectId.toString());
    await Directory(storagePath).create(recursive: true);
    final projectType = parseProjectType(manifest.task);

    return PublicProject(
      projectId,
      "OpenVINO/${manifest.id}",
      currentApplicationVersion,
      manifest.name,
      DateTime.now().toIso8601String(),
      projectType,
      storagePath,
      manifest,
    );
  }

  static PublicProject fromJson(Map<String, dynamic> json, String storagePath) {
    final project = PublicProject(
      json['id'],
      json['model_id'],
      json['application_version'],
      json['name'],
      json['creation_time'],
      parseProjectType(json['type']),
      storagePath,
      ModelManifest.fromJson(json["manifest"]),
    );

    return project;
  }
}
