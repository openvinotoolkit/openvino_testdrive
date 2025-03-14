// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_svg/svg.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/project_provider.dart';

class Model {
  final String name;
  final String taskType;
  final String path;

  Model({
      required this.name,
      required this.taskType,
      required this.path,
  });
}

class WorkflowEditorAssets {
  final Map<String, PictureInfo> icons;
  final List<Model> models;

  WorkflowEditorAssets({
      required this.icons,
      required this.models,
  });

  static Future<Map<String, PictureInfo>> fetchIcons(List<String> paths) async {
    final icons = await Future.wait(paths.map((path) async {
        return MapEntry<String, PictureInfo>(
          path,
          await vg.loadPicture(SvgPicture.asset(path).bytesLoader, null)
        );
    }));
    return Map.fromEntries(icons);
  }

  static List<Model> getModelDictionary(ProjectProvider projectsProvider) {
    List<Model> models = [];
    for (var project in projectsProvider.projects) {
        if (project is GetiProject) {
          for (final task in project.tasks) {
            models.add(Model(
               name: task.name,
               taskType: task.taskType,
               path: task.modelPaths.first,
            ));
          }
        } else {
          models.add(Model(
              name: project.name,
              taskType: projectTypeToString(project.type),
              path: project.storagePath,
          ));
        }
    }
    return models;
  }

  static Future<WorkflowEditorAssets> load({
      required List<String> icons,
      required ProjectProvider projectsProvider,
  }) async {
    return WorkflowEditorAssets(
      icons: await fetchIcons(icons),
      models: getModelDictionary(projectsProvider),
    );
  }
}
