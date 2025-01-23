// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:inference/interop/sentence_transformer.dart';
import 'package:langchain/langchain.dart';

class OpenVINOEmbeddings implements Embeddings {
  final SentenceTransformer transformer;
  const OpenVINOEmbeddings(this.transformer);

  static Future<OpenVINOEmbeddings> init(String modelPath, String device) async {
    return OpenVINOEmbeddings(await SentenceTransformer.init(modelPath, "CPU"));
  }

  @override
  Future<List<List<double>>> embedDocuments(List<Document> documents) {
    return Future.wait(documents.map((document) {
       return embedQuery(document.pageContent);
    }));
  }

  @override
  Future<List<double>> embedQuery(String query) {
    return transformer.generate(query);
  }
}
