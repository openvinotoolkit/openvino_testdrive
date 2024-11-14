import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inference/public_model_info.dart';
import 'package:inference/utils/get_public_thumbnail.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
String genUUID() => uuid.v4().toString();
final platformContext = Context(style: Style.platform);

const currentApplicationVersion = "1.0.0";


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

enum ProjectType { image, text, textToImage, speech }
ProjectType parseProjectType(String name) {
  if (name == "image") {
    return ProjectType.image;
  }
  if (name == "text"){
    return ProjectType.text;
  }
  if (name == "textToImage"){
    return ProjectType.textToImage;
  }
  if (name == "speech") {
    return ProjectType.speech;
  }

  throw UnimplementedError();
}

String projectTypeToString(ProjectType type) {
  switch(type){
    case ProjectType.text:
      return "text";
    case ProjectType.textToImage:
      return "textToImage";
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
  List<Task> tasks = [];
  Completer<void> loaded = Completer<void>();
  bool isPublic;
  bool hasSample = false;

  List<Label> labels() {
    return tasks.map((t) => t.labels).expand((i) => i).where((label) => !label.isEmpty).toList();
  }

  String samplePath() {
    return platformContext.join(storagePath, "sample.jpg");
  }

  String taskName() {
    return tasks.map((task) => task.name).join('->');
  }

  List<Label> get labelDefinitions {
    return tasks.map((t) => t.labels).flattened.toList();
  }

  bool get isDownloaded => true;

  Project(this.id, this.modelId, this.applicationVersion, this.name, this.creationTime, this.type, this.storagePath, this.isPublic);

  Object toMap() {
    return {
      "id": id,
      "model_id": modelId,
      "name": name,
      "creation_time": creationTime,
      "type": projectTypeToString(type),
      "tasks": tasks.map((task) => task.toMap()).toList(),
      "application_version": applicationVersion,
      "is_public": isPublic,
      "has_sample": hasSample,
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

  bool verify() {
    final checks = [
      File(platformContext.join(storagePath, "project.json")).existsSync(),
    ];

    if (isDownloaded) {

      checks.addAll(tasks.map((task) => task.modelPaths).expand((v) => v).map((path) {
          return File(platformContext.join(storagePath, path)).existsSync();
      }));

      checks.addAll([
          //File(platformContext.join(storagePath, "sample.jpg")).existsSync(),
          File(platformContext.join(storagePath, "thumbnail.jpg")).existsSync(),
      ]);
    }

    return !checks.contains(false);
  }
}

class GetiProject extends Project {
  GetiProject(String id, String modelId, String applicationVersion, String name, String creationTime, ProjectType type, String storagePath)
    : super(id, modelId, applicationVersion, name, creationTime, type, storagePath, false);

  List<Score?> scores() {
    return tasks.map((t) => t.performance).toList();
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

  static GetiProject fromJson(json, String storagePath) {
    if (json["application_version"] != "1.0.0") {
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
    project.tasks = List.from(json["tasks"].map((task) => Task.fromJson(task)));
    return project;
  }

  @override
  bool operator ==(rhs) {
    print("operator: ");
    if (rhs is! Project){
      return false;
    }

    if (rhs.id != id) {
      return false;
    }

    return const ListEquality().equals(
      rhs.tasks.map((m) => m.id).toList(),
      tasks.map((m) => m.id).toList()
    );
  }
  bool verify() {
    final platformContext = Context(style: Style.platform);
    final checks = [
      File(platformContext.join(storagePath, "project.json")).existsSync(),
    ];

    checks.addAll(tasks.map((task) => task.modelPaths).expand((v) => v).map((path) {
        return File(platformContext.join(storagePath, path)).existsSync();
    }));

    checks.addAll([
        File(platformContext.join(storagePath, "sample.jpg")).existsSync(),
        File(platformContext.join(storagePath, "thumbnail.jpg")).existsSync(),
    ]);

    return !checks.contains(false);
  }
}

class PublicProject extends Project {
  Completer<void> loaded = Completer<void>();
  Image thumbnail;
  PublicModelInfo? modelInfo;

  PublicProject(String id, String modelId, String applicationVersion, String name, String creationTime, ProjectType type, String storagePath, this.thumbnail, this.modelInfo)
    : super(id, modelId, applicationVersion, name, creationTime, type, storagePath, true);

  @override
  ImageProvider thumbnailImage() {
    return thumbnail.image;
  }

  @override
  bool get isDownloaded => loaded.isCompleted;

  static PublicProject fromJson(Map<String, dynamic> json, String storagePath) {
    final project = PublicProject(
      json['id'],
      json['model_id'],
      json['application_version'],
      json['name'],
      json['creation_time'],
      parseProjectType(json['type']),
      storagePath,
      getThumbnail(json['name']),
      null
    );

    project.tasks = List<Task>.from(json['tasks'].map((t) => Task.fromJson(t)));
    return project;
  }
}
