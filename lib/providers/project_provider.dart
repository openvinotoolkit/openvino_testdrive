// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/project.dart';

class ProjectProvider extends ChangeNotifier {
    final List<Project> _projects = [];

    bool _publicLoaded = false;
    bool get publicLoaded => _publicLoaded;
    set publicLoaded(bool value) {
        _publicLoaded = value;
        notifyListeners();
    }

    UnmodifiableListView<Project> get projects => UnmodifiableListView(_projects);

    ProjectProvider(List<Project> projects) {
        _projects.addAll(projects);
    }

    void addProject(Project project) {
        addProjects([project]);
    }

    void addProjects(List<Project> projects) {
        for (final project in projects) {
            _projects.add(project);
        }
        notifyListeners();
    }

    void removeProject(Project project) async {
        deleteProjectData(project);
        _projects.remove(project);
        notifyListeners();
    }

    void completeLoading(Project project) {
        if (!project.loaded.isCompleted) {
            project.loaded.complete();
        }
        notifyListeners();
    }

}
