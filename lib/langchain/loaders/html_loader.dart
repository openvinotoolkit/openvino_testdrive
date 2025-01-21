import 'dart:io';
import 'package:html/parser.dart';

import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';


class HTMLLoader extends BaseDocumentLoader {

  final String path;
  final CharacterTextSplitter splitter;
  const HTMLLoader(this.path, this.splitter);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final data = await File(path).readAsString();
    final text = parse(data).body?.text;
    if (text != null) {
      for (final content in splitter.splitText(text)) {
        yield Document(
          id: uuid.v4().toString(),
          pageContent: content,
          metadata: {"source": path},
        );
      }
    }
  }
}
