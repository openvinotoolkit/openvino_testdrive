// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:inference/importers/model_manifest.dart';
import 'package:inference/project.dart';

Project largeLanguageModel() {
  return PublicProject(
    "test-llm",
    "OpenVINO/TinyLlama-1.1B-Chat-v1.0-fp16-ov",
    currentApplicationVersion,
    "TinyLlama 1.1B Chat V1.0",
    DateTime.now().toIso8601String(),
    ProjectType.text,
    "/dev/null",
    ModelManifest.fromJson(
      {
        "name": "TinyLlama 1.1B",
        "id": "TinyLlama-1.1B",
        "fileSize": 2205893490,
        "optimizationPrecision": "fp16",
        "contextWindow": 2048,
        "description": "Chat with TinyLlama",
        "task": "text-generation",
        "author": "OpenVINO",
        "collection": "llm-6687aaa2abca3bbcec71a9bd"
      },
    ),
  );
}

PublicProject visualLanguageModel() {
  return PublicProject(
    "test-vlm",
    "OpenVINO/InternVL2-2B-int4-ov",
    currentApplicationVersion,
    "InternVL2-2B-int4-ov",
    DateTime.now().toIso8601String(),
    ProjectType.vlm,
    "/dev/null",
    ModelManifest.fromJson(
      {
        "name": "InternVL2 2B",
        "id": "InternVL2-2B-int4-ov",
        "fileSize": 1543251481,
        "optimizationPrecision": "int4",
        "contextWindow": 0,
        "description": "Let images be described by InternVL2",
        "task": "image-text-to-text",
        "author": "OpenVINO",
        "collection": "visual-language-models-6792248a0eed57085d2b094b"
      },
    ),
  );
}

GetiProject getiProject() {
   return GetiProject.fromJson({
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
  }, "/dev/null")..size = 0;

}
