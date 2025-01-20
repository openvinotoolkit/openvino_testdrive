import 'dart:io';
import 'dart:math';

import 'package:inference/pages/knowledge_base/utils/text_snipper.dart';
import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class TextLoader extends BaseDocumentLoader {

  final String path;
  final TextSnipper snipper;
  const TextLoader(this.path, this.snipper);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await File(path).readAsString();
    for (final content in snipper.snip(text)) {
      yield Document(
        id: uuid.v4().toString(),
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }
}
