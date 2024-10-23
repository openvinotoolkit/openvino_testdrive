import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:inference/utils/get_public_thumbnail.dart';

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