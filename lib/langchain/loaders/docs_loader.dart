// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class DocxLoader extends BaseDocumentLoader {

  final String path;
  final CharacterTextSplitter splitter;
  const DocxLoader(this.path, this.splitter);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await _readFile();
    for (final content in splitter.splitText(text)) {
      yield Document(
        id: uuid.v4().toString(),
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }

  Future<String> _readFile() async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    return docxToText(bytes);
  }
}
