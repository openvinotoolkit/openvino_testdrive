// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:core';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/project.dart';

class Option {
  final String name;
  final String filter;

  const Option(this.name, this.filter);
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

  List<String> _optimizations = [];
  List<String> get optimizations => _optimizations;
  set optimizations(List<String> optimizations) {
    _optimizations = optimizations;
    notifyListeners();
  }

  void addOptimization(String opt) {
    _optimizations.add(opt);
    notifyListeners();
  }

  void removeOptimization(String opt) {
    _optimizations.remove(opt);
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

  List<Model> applyFilterOnModel(List<Model> projects) {
    var filtered = projects
      .where((project) =>
          project.id.toLowerCase().contains((name ?? "").toLowerCase())
      );

    if (optimizations.isNotEmpty) {
      filtered = filtered.where((model) => optimizations.contains(model.optimizationPrecision)).toList();
    }

    if (option != null) {
      filtered = filtered.where((model) => model.task == option!.filter);
    }

    final filteredList = filtered.toList();
    filteredList.sort((a,b) => a.name.compareTo(b.name) * (order ? -1 : 1));

    return filteredList;
  }
}
