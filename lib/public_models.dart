import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inference/project.dart';
import 'package:inference/public_model_info.dart';
import 'package:path/path.dart';

final platformContext = Context(style: Style.platform);

const huggingFaceURL = "https://huggingface.co";

const huggingFaceCollectionInfoUrl = "https://huggingface.co/api/collections/OpenVINO/llm-6687aaa2abca3bbcec71a9bd";

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
  final config = jsonDecode((await http.get(Uri.parse(configJsonURL))).body);
  project.tasks[0].architecture = config["architectures"][0];
  writeProjectJson(project);
}

Map<String, String> llmDownloadFiles(PublicProject project) {
  const files = [
    "openvino_model.bin",
    "openvino_model.xml",
    "openvino_detokenizer.bin",
    "openvino_detokenizer.xml",
    "openvino_tokenizer.bin",
    "openvino_tokenizer.xml",
    "tokenizer_config.json",
    "tokenizer.json",
    "config.json"
  ];

  return { for (var v in files) huggingFaceModelFileUrl(project.id, v) : platformContext.join(project.storagePath, v) };
}

String huggingFaceModelFileUrl(String modelId, String name) {
  return "$huggingFaceURL/$modelId/resolve/main/$name?download=true";
}

Future<List<PublicModelInfo>> getPublicModels() async {
  //final directory = await getApplicationSupportDirectory();
  List<PublicModelInfo> models = [];

  final collectionInfo = jsonDecode((await http.get(Uri.parse(huggingFaceCollectionInfoUrl))).body);
  for (final item in collectionInfo["items"]) {
    models.add(PublicModelInfo.fromJson(item));
  }
  models.sort((a, b) => a.name.compareTo(b.name));
  return models;
}
