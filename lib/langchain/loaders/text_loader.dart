import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class TextLoader extends BaseDocumentLoader {

  final String path;
  final CharacterTextSplitter splitter;
  const TextLoader(this.path, this.splitter);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await File(path).readAsString();
    for (final content in splitter.splitText(text)) {
      yield Document(
        id: uuid.v4().toString(),
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }
}
