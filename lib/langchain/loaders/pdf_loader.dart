// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:inference/utils/pdf_parser.dart';
import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class PdfLoader extends BaseDocumentLoader {

  final String path;
  final CharacterTextSplitter splitter;
  const PdfLoader(this.path, this.splitter);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await PdfToTextParser.convertPdfToText(path);
    for (final content in splitter.splitText(text)) {
      yield Document(
        id: uuid.v4().toString(),
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }
}
