// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:collection/collection.dart';
import 'package:inference/importers/model_manifest.dart';
import 'package:inference/migration/migration.dart';

class MigrationManager {
  final String destinationVersion;
  final List<ModelManifest> manifest;

  List<Migration> migrations;
  MigrationManager({
      required this.destinationVersion,
      required this.manifest,
      required this.migrations,
  });

  bool eligible(Map<String, dynamic> json) {
    return migrations.firstWhereOrNull((migration) {
      return migration.from == json["application_version"];
    }) != null;
  }

  Map<String, dynamic> migrate(Map<String, dynamic> json) {
    Map<String, dynamic> output = json;
    while(true) {
      if (output["application_version"] == destinationVersion) {
        return output;
      }

      final migration = migrations.firstWhereOrNull((migration) {
        return migration.from == output["application_version"];
      });
      if (migration == null) {
        return output;
      }

      output = migration.migrate(output, manifest);
    }
  }
}
