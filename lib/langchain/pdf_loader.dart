import 'dart:math';

import 'package:inference/interop/pdf_extractor.dart';
import 'package:langchain/langchain.dart';

class PdfLoader extends BaseDocumentLoader {

  final String path;
  const PdfLoader(this.path);

  @override
  Stream<Document> lazyLoad() async* {
    final sentences = await getSentencesFromPdf(path);
    for (final sentence in sentences) {
      if (sentence.length < 20) {
        continue;
      }
      yield Document(
        pageContent: sentence,
        metadata: {"source": path},
      );
    }
  }
}

class PdfWindowLoader extends BaseDocumentLoader {

  final String path;
  final int windowSize;
  const PdfWindowLoader(this.path, this.windowSize);

  @override
  Stream<Document> lazyLoad() async* {
    final text = await getTextFromPdf(path);
    for (int i = 0; i < text.length; i += windowSize) {
      final content = text.substring(i, min(i + windowSize, text.length));
      yield Document(
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }
}
