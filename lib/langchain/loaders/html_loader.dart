import 'dart:io';
import 'package:html/parser.dart';
import 'package:inference/pages/knowledge_base/utils/text_snipper.dart';

import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';


class HTMLLoader extends BaseDocumentLoader {

  final String path;
  final TextSnipper snipper;
  const HTMLLoader(this.path, this.snipper);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final data = await File(path).readAsString();
    final text = parse(data).body?.text;
    if (text != null) {
      for (final content in snipper.snip(text)) {
        yield Document(
          id: uuid.v4().toString(),
          pageContent: content,
          metadata: {"source": path},
        );
      }
    }
  }
}
