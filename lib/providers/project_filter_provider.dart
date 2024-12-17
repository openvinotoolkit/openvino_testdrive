// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:core';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/project.dart';
import 'package:inference/public_model_info.dart';

class Option {
  final String name;
  final String filter;

  const Option(this.name, this.filter);

  static Map<String, List<Option>> get filterOptions {
    var options = {
      "Image": [
        const Option("Detection", "detection"),
        const Option("Classification", "classification"),
        const Option("Segmentation", "segmentation"),
        const Option("Anomaly detection","anomaly")
      ],
      "Text": [
        const Option("Text generation", "text")
      ],
      "Audio": [
        const Option("Speech to text", "speech")
      ]
    };

    return options;
  }
}


class ProjectFilterProvider extends ChangeNotifier {
  bool _order = false;
  bool get order => _order;
  set order(bool o) {
    _order = o;
    notifyListeners();
  }

  Option? _option;

  Option? get option => _option;
  set option(Option? opt) {
    _option = opt;
    notifyListeners();
  }

  final List<String> optimizations = [];

  void addOptimization(String opt) {
    optimizations.add(opt);
    notifyListeners();
  }

  void removeOptimization(String opt) {
    optimizations.remove(opt);
    notifyListeners();
  }

  String? _name;
  String? get name => _name;
  set name(String? name) {
    _name = name;
    notifyListeners();
  }

  List<Project> applyFilter(List<Project> projects) {
    var filtered = projects
      .where((project) =>
          project.name.toLowerCase().contains((name ?? "").toLowerCase())
      )
      .where((project) => project.tasks.where((t) {
        if (option == null) {
          return true;
        }
        return t.taskType.contains(option!.filter);
      }).isNotEmpty);

    final filteredList = filtered.toList();

    filteredList.sort((a,b) => a.name.compareTo(b.name) * (order ? -1 : 1));
    return filteredList;
  }

  List<PublicModelInfo> applyFilterOnPublicModelInfo(List<PublicModelInfo> projects) {
    var filtered = projects
      .where((project) =>
          project.id.toLowerCase().contains((name ?? "").toLowerCase())
      );

    if (optimizations.isNotEmpty) {
      filtered = filtered.where((model) {
          return optimizations.where((opt) {
              return model.name.contains(opt);
          }).isNotEmpty;
      });
    }

    if (option != null) {
      filtered = filtered.where((model) => model.taskType == option!.filter);
    }


    return filtered.toList();
  }
}
