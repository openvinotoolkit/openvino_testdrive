// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:inference/importers/model_manifest.dart';

class ManifestImporter {
  final String manifestPath;
  List<ModelManifest> popularModels = [];
  List<ModelManifest> allModels = [];

  ManifestImporter(this.manifestPath);

  Future<void> loadManifest() async {
    final contents = await rootBundle.loadString(manifestPath);
    final jsonData = jsonDecode(contents);

    popularModels = (jsonData['popular_models'] as List)
        .map((modelJson) => ModelManifest.fromJson(modelJson))
        .toList();

    allModels = (jsonData['all_models'] as List)
        .map((modelJson) => ModelManifest.fromJson(modelJson))
        .toList();
  }

  List<ModelManifest> getPopularModels() {
    return popularModels;
  }

  List<ModelManifest> getAllModels() {
    return allModels;
  }
}
