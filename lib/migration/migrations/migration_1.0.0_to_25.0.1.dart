// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:collection/collection.dart';

import 'package:inference/importers/model_manifest.dart';
import 'package:inference/migration/migration.dart';

class MigrationV1ToV2501 extends Migration {
  MigrationV1ToV2501(): super(from: "1.0.0", to: "25.0.1");

  @override
  Map<String, dynamic> migrate(Map<String, dynamic> input, List<ModelManifest> manifest) {
    ModelManifest? publicModelInfo = manifest.firstWhereOrNull((model) {
        return input["model_id"] == "${model.author}/${model.id}";
    });

    Map<String, dynamic> output = {
      "id": input["id"],
      "model_id": input["model_id"],
      "name": input["name"],
      "creation_time": input["creation_time"],
      "type": input["type"],
      "application_version": "25.0.1",
      "is_public": input["is_public"],
    };

    if (input["is_public"]) {
      output["manifest"] = publicModelInfo?.toJson();
    } else {
      output["geti"] = input["tasks"];
    }

    return output;
  }

}
