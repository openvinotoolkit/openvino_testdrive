// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:inference/importers/model_manifest.dart';
import 'package:inference/migration/migrations/migration_1.0.0_to_25.0.1.dart';

class Migration {
  final String from;
  final String to;
  final Map Function(Map, List<ModelManifest> manifest) migration;

  Map Function(Map, List<ModelManifest> manifest) get migrate => migration;

  Migration({required this.from, required this.to, required this.migration});
}

void main() {

  final migration = MigrationV1ToV2501();

  group("1.0.0 to 25.0.1", () {
    test("migration of geti model", () {
        List<ModelManifest> manifest = [];

        final subject = {
          "id": "662aac1fedcb02d8b6323097",
          "model_id": "81f7b802-e020-4dcb-ad10-9a32461de06d",
          "name": "Cattle detection",
          "creation_time": "2024-04-25T19:16:51.714000+00:00",
          "type": "image",
          "tasks": [
            {
              "id": "662aac23edcb02d8b632309a",
              "name": "Detection",
              "task_type": "detection",
              "model_paths": [
                "662aac23edcb02d8b632309a.xml"
              ],
              "performance": 0.8999999999999999,
              "labels": [
                {
                  "id": "662aac23edcb02d8b632309c",
                  "name": "Cow",
                  "color": "#ff7d00ff",
                  "is_empty": false
                },
                {
                  "id": "662aac23edcb02d8b632309d",
                  "name": "Sheep",
                  "color": "#076984ff",
                  "is_empty": false
                },
                {
                  "id": "662aac23edcb02d8b63230a1",
                  "name": "No object",
                  "color": "#000000ff",
                  "is_empty": true
                }
              ],
              "architecture": "MobileNetV2-ATSS",
              "optimization": "OpenVINO INT8"
            }
          ],
          "application_version": "1.0.0",
          "is_public": false,
          "has_sample": true
        };

        final expectation = {
          "id": "662aac1fedcb02d8b6323097",
          "model_id": "81f7b802-e020-4dcb-ad10-9a32461de06d",
          "name": "Cattle detection",
          "creation_time": "2024-04-25T19:16:51.714000+00:00",
          "type": "image",
          "geti": [
            {
              "id": "662aac23edcb02d8b632309a",
              "name": "Detection",
              "task_type": "detection",
              "model_paths": [
                "662aac23edcb02d8b632309a.xml"
              ],
              "performance": 0.8999999999999999,
              "labels": [
                {
                  "id": "662aac23edcb02d8b632309c",
                  "name": "Cow",
                  "color": "#ff7d00ff",
                  "is_empty": false
                },
                {
                  "id": "662aac23edcb02d8b632309d",
                  "name": "Sheep",
                  "color": "#076984ff",
                  "is_empty": false
                },
                {
                  "id": "662aac23edcb02d8b63230a1",
                  "name": "No object",
                  "color": "#000000ff",
                  "is_empty": true
                }
              ],
              "architecture": "MobileNetV2-ATSS",
              "optimization": "OpenVINO INT8"
            }
          ],
          "is_public": false,
          "application_version": "25.0.1",
        };

        expect(migration.migrate(subject, manifest), expectation);
    });
    test("migration of public model", () {

        List<ModelManifest> manifest = [
          ModelManifest.fromJson({
            "name": "Whisper Base",
            "id": "whisper-base-fp16-ov",
            "fileSize": 251616604,
            "optimizationPrecision": "fp16",
            "contextWindow": 0,
            "description": "We make it easy to connect with people: Use Whisper to transcribe videos",
            "task": "speech",
            "author": "OpenVINO",
            "collection": "speech-to-text-672321d5c070537a178a8aeb",
            "npuEnabled": true
          })
        ];

        final subject = {
          "id": "0154cef8-2ec6-4f9e-bef0-df5f0badda87",
          "model_id": "OpenVINO/whisper-base-fp16-ov",
          "name": "Whisper Base",
          "creation_time": "2025-02-28T11:12:03.685055",
          "type": "speech",
          "tasks": [
            {
              "id": "d3c54520-1666-4d48-91f1-69a84870f8e9",
              "name": "speech",
              "task_type": "speech",
              "model_paths": [],
              "performance": null,
              "labels": [],
              "architecture": "WhisperForConditionalGeneration",
              "optimization": ""
            }
          ],
          "application_version": "1.0.0",
          "is_public": true,
          "has_sample": false
        };

        final expectation = {
          "id": "0154cef8-2ec6-4f9e-bef0-df5f0badda87",
          "model_id": "OpenVINO/whisper-base-fp16-ov",
          "name": "Whisper Base",
          "creation_time": "2025-02-28T11:12:03.685055",
          "type": "speech",
          "manifest": {
            "name": "Whisper Base",
            "id": "whisper-base-fp16-ov",
            "fileSize": 251616604,
            "optimizationPrecision": "fp16",
            "contextWindow": 0,
            "description": "We make it easy to connect with people: Use Whisper to transcribe videos",
            "task": "speech",
            "author": "OpenVINO",
            "collection": "speech-to-text-672321d5c070537a178a8aeb",
            "npuEnabled": true,
            "architecture": "unknown"
          },
          "is_public": true,
          "application_version": "25.0.1",
        };

        expect(migration.migrate(subject, manifest), expectation);
    });
  });
}
