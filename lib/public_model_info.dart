// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/project.dart';
import 'package:inference/utils/get_public_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class Collection {
  final String path;
  final String token;
  final String type;
  const Collection(this.path, this.token, this.type);
}


class PublicModelInfo {
  final String id;
  final String lastModified;
  final int likes;
  final int downloads;
  final String taskType;
  final Collection collection;

  const PublicModelInfo(this.id, this.lastModified, this.likes, this.downloads, this.taskType, this.collection);

  factory PublicModelInfo.fromJson(Map<String, dynamic> json, String taskType, Collection collection) {
    return switch (json) {
      {'id': String id, 'lastModified': String lastModified, 'likes': int likes, 'downloads': int downloads}
        => PublicModelInfo(id, lastModified, likes, downloads, taskType, collection),
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
