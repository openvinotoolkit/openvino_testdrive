import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inference/project.dart';
import 'package:inference/public_model_info.dart';
import 'package:inference/utils.dart';
import 'package:path/path.dart';

final platformContext = Context(style: Style.platform);

const huggingFaceURL = "https://huggingface.co";

const List<Collection> collections = [
  Collection("https://huggingface.co/api/collections/OpenVINO/llm-6687aaa2abca3bbcec71a9bd", "", "text"),
  Collection("https://huggingface.co/api/collections/OpenVINO/speech-to-text-672321d5c070537a178a8aeb", "", "speech"),
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

Future<List<String>> getFilesForModel(String modelId) async {
  final dio = dioClient();
  final result = await dio.get("https://huggingface.co/api/models", queryParameters: {"search":modelId,"author":"OpenVINO","limit":1,"full":"True","config":"True"});
  return List<String>.from(result.data[0]["siblings"].map((m) => m.values.first));
}

Future<Map<String, String>> downloadFiles(PublicProject project) async {
  final files = await getFilesForModel(project.id);
  return { for (var v in files) huggingFaceModelFileUrl(project.id, v) : platformContext.join(project.storagePath, v) };
}

String huggingFaceModelFileUrl(String modelId, String name) {
  return "$huggingFaceURL/$modelId/resolve/main/$name?download=true";
}

Future<List<PublicModelInfo>> getPublicModels() async {
  //final directory = await getApplicationSupportDirectory();
  List<PublicModelInfo> models = [];

  for (final collection in collections) {
    final dio = dioClient();
    final request = await dio.get(collection.path);
    final collectionInfo = jsonDecode(request.toString());
    for (final item in collectionInfo["items"]) {
      models.add(PublicModelInfo.fromJson(item, collection.type, collection));
    }
  }
  models.sort((a, b) => a.name.compareTo(b.name));
  return models;
}
