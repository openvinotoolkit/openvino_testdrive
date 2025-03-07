// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/importers/model_manifest.dart';

class ImportProvider extends ChangeNotifier {
  Future<List<ModelManifest>>? allModelsFuture;
  ModelManifest? _selectedModel;
  ModelManifest? get selectedModel => _selectedModel;
  set selectedModel(ModelManifest? model) {
    _selectedModel = model;
    notifyListeners();
  }

  ImportProvider() {
    final importer = ManifestImporter('assets/manifest.json');
    allModelsFuture = importer.loadManifest().then((_) => importer.getAllModels());
    selectedModel = null;
  }

}
