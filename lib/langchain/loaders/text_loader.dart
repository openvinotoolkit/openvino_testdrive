import 'dart:io';
import 'dart:math';

import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class TextLoader extends BaseDocumentLoader {

  final String path;
  final int windowSize;
  const TextLoader(this.path, this.windowSize);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await File(path).readAsString();
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
