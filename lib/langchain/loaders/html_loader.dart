import 'dart:io';
import 'dart:math';
import 'package:html/parser.dart';

import 'package:langchain/langchain.dart';

class HTMLLoader extends BaseDocumentLoader {

  final String path;
  final int windowSize;
  const HTMLLoader(this.path, this.windowSize);

  @override
  Stream<Document> lazyLoad() async* {
    final data = await File(path).readAsString();
    final text = parse(data).body?.text;
    if (text != null) {
      for (int i = 0; i < text.length; i += windowSize) {
        final content = text.substring(i, min(i + windowSize, text.length));
        yield Document(
          pageContent: content,
          metadata: {"source": path},
        );
      }
    }
  }
}
