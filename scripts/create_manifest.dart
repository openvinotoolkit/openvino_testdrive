// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

class Collection {
  final String path;
  final String collectionAuthor;
  final String modelAuthor;
  final String fallbackTask;
  final String Function(String) descriptionFormat;

  const Collection(this.path, this.collectionAuthor, this.modelAuthor,
      this.fallbackTask, this.descriptionFormat);
}

class HuggingFaceFileEntry {
  final String type;
  final String path;
  final int size;

  HuggingFaceFileEntry(
      {required this.type, required this.path, required this.size});

  factory HuggingFaceFileEntry.fromJson(Map<String, dynamic> json) {
    return HuggingFaceFileEntry(
      type: json['type'],
      path: json['path'],
      size: json['size'] ?? 0,
    );
  }
}

Future<List<Map<String, dynamic>>> getCollectionConfig(
    Collection collection) async {
  final url =
      "https://huggingface.co/api/collections/${collection.collectionAuthor}/${collection.path}";
  final request = await http.get(Uri.parse(url));
  return List<Map<String, dynamic>>.from(jsonDecode(request.body)["items"]);
}

class ModelInfo {
  //Example
  //"Name": "Open Llama",
  //"Id": "open_llama_3b_v2-fp16-ov",
  //"File_Size": "2GB",
  //"Optimization_Precision": "int 4",
  //"Context_Window": "4k tokens",
  //"description": "Chat with Open Llama model",
  //"Task": "Chat"

  final String name;
  final String id;
  final int fileSize;
  final String optimizationPrecision;
  final int contextWindow;
  String description = "";
  final String task;
  final String author;
  final String collection;

  ModelInfo({
      required this.name,
      required this.id,
      required this.fileSize,
      required this.optimizationPrecision,
      required this.contextWindow,
      required this.description,
      required this.task,
      required this.author,
      required this.collection,
  });

  Object toMap() {
    return {
        "name": name,
        "id": id,
        "fileSize": fileSize,
        "optimizationPrecision": optimizationPrecision,
        "contextWindow": contextWindow,
        "description": description,
        "task": task,
        "author": author,
        "collection": collection,
    };
  }

  static Future<ModelInfo> fromCollectionConfig(Map<String, dynamic> collectionConfig, Collection collection) async {
    final id = getIdFromHuggingFaceId(collectionConfig["id"]);
    final name = getNameFromId(id);

    final config = await getConfigFromRepo(id, collection.modelAuthor);
    final fileSize = await getModelSizeCrawler(id, collection.modelAuthor);
    final description = collection.descriptionFormat(name);

    int contextWindow = config["max_position_embeddings"]
      ?? config["max_seq_len"]
      ?? config["n_positions"]
      ?? 0;

    return ModelInfo(
      name: getNameFromId(id),
      id: id,
      fileSize: fileSize,
      optimizationPrecision: getOptimizationFromId(id) ?? "",
      contextWindow: contextWindow,
      description: description,
      task: collectionConfig["pipeline_tag"] ?? collection.fallbackTask,
      author: collection.modelAuthor,
      collection: collection.path,
    );
  }

  static Future<Map<String, int>> getFileSizesRecursively(
      String id, String author, String path) async {
    String url = "https://huggingface.co/api/models/$author/$id/tree/main";
    if (path.isNotEmpty) {
      url += path;
    }

    Map<String, int> map = {};

    final response = await http.get(Uri.parse(url));
    final List<HuggingFaceFileEntry> document = (jsonDecode(response.body) as List<dynamic>)
        .map((e) => HuggingFaceFileEntry.fromJson(e))
        .toList();

    for (final entry in document) {
      if (entry.type == "directory") {
        final p = entry.path;
        final entries = await getFileSizesRecursively(id, author, "$path/$p");
        map.addAll(entries);
      } else if (entry.type == "file"){
        map[entry.path] = entry.size;
      }
    }

    return map;
  }

  static Future<int> getModelSizeCrawler(String id, String author) async {
    final fileSizesMap = await getFileSizesRecursively(id, author, "");
    return fileSizesMap.values.reduce((sum, element) => sum + element);
  }

  static Future<Map<String, dynamic>> getConfigFromRepo(
      String id, String author) async {
    final url = "https://huggingface.co/$author/$id/raw/main/config.json";
    final response = await http.get(Uri.parse(url));
    final result = response.body;
    if (response.statusCode == 200) {
      final config = jsonDecode(result);
      return config;
    }
    return {};
  }

  static String? getOptimizationFromId(String id) {
    final optimizationPattern = RegExp("(fp|int)(\\d*)");
    final match = optimizationPattern.firstMatch(id);
    if (match != null) {
      return match.group(0);
    }
    return null;
  }

  static String getIdFromHuggingFaceId(String huggingFaceId) {
    final pattern = RegExp(".*/(.*)");
    return pattern.firstMatch(huggingFaceId)!.group(1)!;
  }

  static String capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }

  static String getNameFromId(String id) {
    final pattern = RegExp("((fp|int)(\\d*)|ov)");
    final sections = id.split(RegExp("[-_]"));
    List<String> parts = [];
    for (final section in sections) {
      final match = pattern.firstMatch(section);
      if (match == null) {
        parts.add(capitalize(section));
      }
    }

    return parts.join(" ");
  }
}

void generate() async {

  final popular = {
    "InternVL2-2B-int4-ov": "Let images be described by InternVL2",
    "whisper-base-fp16-ov": "We make it easy to connect with people: Use Whisper to transcribe videos",
    "open_llama_3b_v2-int8-ov": "Unlock the Power of AI on Your PC: Start Chatting with the Mistral 7b Instruct",
    "LCM_Dreamshaper_v7-int8-ov": "Generate images with Dreamshaper V7",
  };

  final List<Collection> collections = [
    Collection("speech-to-text-672321d5c070537a178a8aeb", "OpenVINO", "OpenVINO", "speech", (String name) => "Transcribe video with $name"),
    Collection("visual-language-models-6792248a0eed57085d2b094b", "OpenVINO", "OpenVINO", "vlm", (String name) => "Understand images with $name"),
    Collection("llm-6687aaa2abca3bbcec71a9bd", "OpenVINO", "OpenVINO", "text-generation", (String name) => "Chat with $name"),
    Collection("image-generation-6763eab8ac097237330c78c5", "arendjan", "OpenVINO", "text-to-image", (String name) => "Generate images with $name"),
  ];
  List<ModelInfo> models = [];
  for (final collection in collections) {
    final collectionModels = await getCollectionConfig(collection);
    for (final collectionModel in collectionModels) {
      models.add(await ModelInfo.fromCollectionConfig(collectionModel, collection));
    }
  }

  Map<String, dynamic> result = {};

  var popularModels = popular.keys.map((id) => models.firstWhereOrNull((r) => r.id == id)).whereType<ModelInfo>();
  for (var model in popularModels){
    model.description = popular[model.id] ?? model.description;
  }

  result['popular_models'] = popularModels.map((m) => m.toMap()).toList();
  result['all_models'] = models
      .where((m) => !m.id.toLowerCase().contains('distil-whisper'))
      .map((m) => m.toMap())
      .toList();

  const encoder = JsonEncoder.withIndent("  ");
  print(encoder.convert(result));
}

int main() {
  generate();
  return 0;
}
