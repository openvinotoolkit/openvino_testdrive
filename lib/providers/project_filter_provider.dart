import 'package:flutter/material.dart';
import 'package:inference/config.dart';
import 'package:inference/project.dart';
import 'package:inference/public_model_info.dart';

class Option {
  final String name;
  final String filter;

  const Option(this.name, this.filter);

  static Map<String, List<Option>> get filterOptions {
    var options = {"Image": [
        const Option("Detection", "detection"),
        const Option("Classification", "classification"),
        const Option("Segmentation", "segmentation"),
        const Option("Anomaly detection","anomaly")
      ],
    };
    if (!Config.geti) {
      options["Text"] = [
        const Option("Text generation", "text")
      ];
    }

    return options;
  }
}


class ProjectFilterProvider extends ChangeNotifier {
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

    return filtered.toList();
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
