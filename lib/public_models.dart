// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inference/project.dart';
import 'package:inference/utils.dart';
import 'package:path/path.dart';

final platformContext = Context(style: Style.platform);

const huggingFaceURL = "https://huggingface.co";

void createDirectory(PublicProject project) {
  Directory(project.storagePath).createSync();
}

void writeProjectJson(PublicProject project) {
  final projectFile = platformContext.join(project.storagePath, "project.json");
  const encoder = JsonEncoder.withIndent("  ");
  File(projectFile).writeAsStringSync(encoder.convert((project.toMap())));
}

Future<void> getAdditionalModelInfo(PublicProject project) async {
  final configJsonURL = huggingFaceModelFileUrl(project.modelId, "config.json");
  final response = await http.get(Uri.parse(configJsonURL));
  if (response.statusCode == 200) {
    final config = jsonDecode(response.body);
    project.manifest.architecture = config["architectures"][0];
  }else{
    project.manifest.architecture = "unknown"; // Not all models have config.json
  }
  writeProjectJson(project);
}

Future<List<String>> getFilesForModel(String modelId) async {
  final dio = dioClient();
  final result = await dio.get("https://huggingface.co/api/models", queryParameters: {"search":modelId,"author":"OpenVINO","limit":1,"full":"True","config":"True"});
  return List<String>.from(result.data[0]["siblings"].map((m) => m.values.first));
}

Future<Map<String, String>> listDownloadFiles(PublicProject project) async {
  final files = await getFilesForModel(project.modelId);
  return { for (var v in files) huggingFaceModelFileUrl(project.modelId, v) : platformContext.join(project.storagePath, v) };
}

String huggingFaceModelFileUrl(String modelId, String name) {
  return "$huggingFaceURL/$modelId/resolve/main/$name?download=true";
}
