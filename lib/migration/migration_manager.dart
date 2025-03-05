// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:collection/collection.dart';
import 'package:inference/importers/model_manifest.dart';
import 'package:inference/migration/migration.dart';
import 'package:inference/migration/migrations/migration_1.0.0_to_25.0.1.dart';

class MigrationManager {
  final String destinationVersion;
  final List<ModelManifest> manifest;

  final List<Migration> migrations = [
    MigrationV1ToV2501(),
  ];

  MigrationManager({
      required this.destinationVersion,
      required this.manifest,
  });

  bool eligible(Map<String, dynamic> json) {
    return migrations.firstWhereOrNull((migration) {
      return migration.from == json["application_version"];
    }) != null;
  }

  Map<String, dynamic> migrate(Map<String, dynamic> json) {
    Map<String, dynamic> output = json;
    while(true) {
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
