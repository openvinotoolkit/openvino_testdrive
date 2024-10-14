import 'package:flutter/material.dart';
import 'package:inference/project.dart';
import 'package:inference/utils/get_public_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PublicModelInfo {
  final String id;
  final String lastModified;
  final int likes;
  final int downloads;
  String taskType = "text";

  PublicModelInfo(this.id, this.lastModified, this.likes, this.downloads);

  factory PublicModelInfo.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'id': String id, 'lastModified': String lastModified, 'likes': int likes, 'downloads': int downloads}
        => PublicModelInfo(id, lastModified, likes, downloads),
      _ => throw FormatException('Invalid JSON: $json'),
    };
  }

  Image get thumbnail {
    return getThumbnail(id);
  }

  String get name {
    final [_, model] = id.split("/");
    return model;
  }

  static Future<Project> convertToProject(PublicModelInfo model) async {
    final directory = await getApplicationSupportDirectory();
    final storagePath = platformContext.join(directory.path, const Uuid().v4().toString());
    final projectType = parseProjectType(model.taskType);
    final project = PublicProject(
      model.id,
      model.name,
      "1.0.0",
      model.name,
      model.lastModified,
      projectType,
      storagePath,
      model.thumbnail,
      model
    );

    project.tasks.add(
      Task(
        genUUID(),
        model.taskType,
        model.taskType,
        [],
        null,
        [],
        "",
        ""
      )
    );
    return project;
  }
}
