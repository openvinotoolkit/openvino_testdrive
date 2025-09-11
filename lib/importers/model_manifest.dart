// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';
import 'package:inference/utils.dart';
import 'package:inference/utils/get_public_thumbnail.dart';

class ModelManifest {
  final String name;
  final String id;
  final int fileSize;
  final String optimizationPrecision;
  final int contextWindow;
  final String collection;
  final String description;
  final String task;
  final String author;
  bool npuEnabled;
  String? architecture;

  ModelManifest({
    required this.name,
    required this.id,
    required this.fileSize,
    required this.optimizationPrecision,
    required this.contextWindow,
    required this.collection,
    required this.description,
    required this.task,
    required this.author,
    required this.npuEnabled,
    this.architecture,
  });

  String get kind {
   if (task == 'text-generation'){
     return 'llm';
   } else if (task == 'speech'){
     return 'speech to text';
   } else if (task == 'text-to-image'){
     return 'image generation';
   }
   return 'other';
  }

  String get readableFileSize {
    return fileSize.toDouble().readableFileSize();
  }

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    return ModelManifest(
      name: json['name'],
      id: json['id'],
      fileSize: json['fileSize'],
      optimizationPrecision: json['optimizationPrecision'],
      collection: json['collection'],
      contextWindow: json['contextWindow'],
      description: json['description'],
      task: json['task'],
      author: json['author'],
      architecture: json['architecture'] ?? "unknown",
      npuEnabled: json['npuEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "fileSize": fileSize,
      "optimizationPrecision": optimizationPrecision,
      "contextWindow": contextWindow,
      "description": description,
      "collection": collection,
      "task": task,
      "author": author,
      "architecture": architecture,
      "npuEnabled": npuEnabled
    };
  }

  Image get thumbnail {
    return getThumbnail(id);
  }

}
