import 'dart:io';

import 'package:flutter/services.dart';
import 'package:inference/importers/geti_deployment.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:path_provider/path_provider.dart';

Future<void> copyFromAsset(String assetPath, String outputPath) async {
  final data = await rootBundle.load(assetPath);
  await File(outputPath).writeAsBytes(data.buffer.asUint8List());
}

class AllMiniLMV6 {

  static Future<String> get storagePath {
    return getApplicationSupportDirectory().then((directory) => platformContext.join(directory.path, id));
  }

  static String id = "all-MiniLM-L6-v2";

  static Future<DownloadRequest> buildDownloadRequest(String storagePath) async {
    final downloads = files().map((url, path) {
        return MapEntry(url, platformContext.join(storagePath, path));
    });

    return DownloadRequest(
      id: id,
      downloads: downloads,
    );
  }

  static Future<void> ensureEmbeddingsModel(DownloadProvider downloadProvider) async {
      //steps:
      //1. check if download is in progress
      if (downloadProvider.downloads.containsKey(id)) {
        print("Download was already in progress...");
        await downloadProvider.downloads[id]!.done.future;
        return;
      }

      //2. if not check if model exists on support drive
      final directory = await storagePath;

      if (Directory(directory).existsSync()) {
        print("Model was already downloaded");
        return;
      }

      //3. if not start download of said model
      print("Model not downloaded yet... downloading now");
      final request = await buildDownloadRequest(directory);
      await downloadProvider.requestDownload(request);
      await copyFromAsset("assets/MiniLM-L6-H384-uncased/openvino_tokenizer.xml", platformContext.join(directory, "openvino_tokenizer.xml"));
      await copyFromAsset("assets/MiniLM-L6-H384-uncased/openvino_tokenizer.bin", platformContext.join(directory, "openvino_tokenizer.bin"));
      print("Model downloaded!");
  }

  static Map<String, String> files() {
    return const {
      "https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/refs%2Fpr%2F96/openvino/openvino_model.xml": "openvino_model.xml",
      "https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/refs%2Fpr%2F96/openvino/openvino_model.bin": "openvino_model.bin",
    };
  }
}
