import 'dart:convert';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';

Future<List<Map<String, dynamic>>> getCollectionConfig(String collectionId, String author) async {
  final url = "https://huggingface.co/api/collections/$author/$collectionId";
  final request = await http.get(Uri.parse(url));
  return List<Map<String, dynamic>>.from(jsonDecode(request.body)["items"]);
}

class ModelInfo {
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
  final String description;
  final String task;

  const ModelInfo({
      required this.name,
      required this.id,
      required this.fileSize,
      required this.optimizationPrecision,
      required this.contextWindow,
      required this.description,
      required this.task
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
    };
  }

  static Future<ModelInfo> fromCollectionConfig(Map<String, dynamic> collectionConfig, String author) async {
    final id = getIdFromHuggingFaceId(collectionConfig["id"]);
    final name = getNameFromId(id);

    final config = await getConfigFromRepo(id, author);
    final fileSize = await getModelSizeCrawler(id, author);
    final description = "Chat with $name model";

    return ModelInfo(
      name: getNameFromId(id),
      id: id,
      fileSize: fileSize,
      optimizationPrecision: getOptimizationFromId(id) ?? "",
      contextWindow: config["max_position_embeddings"],
      description: description,
      task: collectionConfig["pipeline_tag"],
    );
  }

  static Future<int> getModelSizeCrawler(String id, String author) async {
    final url = "https://huggingface.co/$author/$id/tree/main";
    final pattern = RegExp("(.*) (.*)");

    final output = await http.get(Uri.parse(url));
    var document = parse(output.body);
    final files = document.querySelectorAll('a[title="Download file"]');

    int total = 0;
    for (final v in files) {
      final text = v.nodes.whereType<Text>().first.text.trim();
      final match = pattern.firstMatch(text);
      if (match == null){
        continue;
      }

      final val = double.parse(match.group(1)!);
      total += (val * switch(match.group(2)!) {
        "Bytes" => 1,
        "kB" => 1024,
        "MB" => 1024 * 1024,
        "GB" => 1024 * 1024 * 1024,
        _ => 0
      }).toInt();
    }
    return total;
  }

  static Future<Map<String, dynamic>> getConfigFromRepo(String id, String author) async {
    final url = "https://huggingface.co/$author/$id/raw/main/config.json";
    final result = (await http.get(Uri.parse(url))).body;
    final config = jsonDecode(result);
    return config;
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
    final pattern =RegExp("((fp|int)(\\d*)|ov)");
    final sections = id.split("-");
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

  final popular = [
    "mistral-7b-instruct-v0.1-int8-ov",
    "Phi-3-mini-4k-instruct-int4-ov",
    "open_llama_3b_v2-int8-ov",
  ];
  final models = await getCollectionConfig("llm-6687aaa2abca3bbcec71a9bd", "OpenVINO");
  List<Object> result = [];
  for (int i = 0; i < 2; i++) {
    final model = models[i];
    result.add((await ModelInfo.fromCollectionConfig(model, "OpenVINO")).toMap());
  }
  const encoder = JsonEncoder.withIndent("  ");

  print(encoder.convert(result));
}

int main() {
  generate();
  return 0;
}
