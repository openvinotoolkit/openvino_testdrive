import 'dart:math';

import 'package:inference/interop/pdf_extractor.dart';
import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class PdfLoader extends BaseDocumentLoader {

  final String path;
  final int windowSize;
  const PdfLoader(this.path, this.windowSize);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await getTextFromPdf(path);
    for (int i = 0; i < text.length; i += windowSize) {
      final content = text.substring(i, min(i + windowSize, text.length));
      yield Document(
        id: uuid.v4().toString(),
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }
}
