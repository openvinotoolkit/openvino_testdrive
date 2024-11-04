import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:http/http.dart' as http;
import 'package:inference/project.dart';
import 'package:inference/public_model_info.dart';
import 'package:inference/utils.dart';
import 'package:path/path.dart';

final platformContext = Context(style: Style.platform);

const huggingFaceURL = "https://huggingface.co";

const List<Collection> collections = [
  Collection("https://huggingface.co/api/collections/OpenVINO/llm-6687aaa2abca3bbcec71a9bd", "", "text"),
  //Collection("https://huggingface.co/api/collections/rhecker/speech-670ba88d40c7862e25913551", "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", "speech"),
];

void createDirectory(PublicProject project) {
  Directory(project.storagePath).createSync();
}

void writeProjectJson(PublicProject project) {
  final projectFile = platformContext.join(project.storagePath, "project.json");
  const encoder = JsonEncoder.withIndent("  ");
  File(projectFile).writeAsStringSync(encoder.convert((project.toMap())));
}

Future<void> getAdditionalModelInfo(PublicProject project) async {
  final configJsonURL = huggingFaceModelFileUrl(project.id, "config.json");
  final config = jsonDecode((await http.get(
      Uri.parse(configJsonURL),
      headers: {
        "Authorization":"Bearer ${project.modelInfo!.collection.token}",
      }
  )).body);
  project.tasks[0].architecture = config["architectures"][0];
  writeProjectJson(project);
}

Map<String, String> downloadFiles(PublicProject project) {
  final files = project.modelInfo?.files() ?? [];
  return { for (var v in files) huggingFaceModelFileUrl(project.id, v) : platformContext.join(project.storagePath, v) };
}

String huggingFaceModelFileUrl(String modelId, String name) {
  return "$huggingFaceURL/$modelId/resolve/main/$name?download=true";
}

Future<List<PublicModelInfo>> getPublicModels() async {
  List<PublicModelInfo> models = [];

  final dio = dioClient();

  for (final collection in collections) {
    final request = await dio.get(collection.path);
    final body = request.toString();
    final collectionInfo = jsonDecode(body);
    for (final item in collectionInfo["items"]) {
      models.add(PublicModelInfo.fromJson(item, collection.type, collection));
    }
  }
  models.sort((a, b) => a.name.compareTo(b.name));
  return models;
}
