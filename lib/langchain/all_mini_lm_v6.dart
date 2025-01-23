import 'dart:io';

import 'package:inference/importers/geti_deployment.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:path_provider/path_provider.dart';

class AllMiniLMV6 {

  static String id = "all-MiniLM-L6-v2";

  static Future<DownloadRequest> buildDownloadRequest() async {
    final directory = await getApplicationSupportDirectory();
    final storagePath = platformContext.join(directory.path, id);
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
      final directory = await getApplicationSupportDirectory();
      if (Directory(platformContext.join(directory.path, id)).existsSync()) {
        print("Model was already downloaded");
        return;
      }

      //3. if not start download of said model
      print("Model not downloaded yet... downloading now");
      final request = await buildDownloadRequest();
      await downloadProvider.requestDownload(request);
      print("Model downloaded!");
  }

  static Map<String, String> files() {
    return const {
      "https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/refs%2Fpr%2F96/openvino/openvino_model.xml": "openvino_model.xml",
      "https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/refs%2Fpr%2F96/openvino/openvino_model.bin": "openvino_model.bin",
    };
  }
}
