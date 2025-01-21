import 'package:inference/interop/pdf_extractor.dart';
import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class PdfLoader extends BaseDocumentLoader {

  final String path;
  final CharacterTextSplitter splitter;
  const PdfLoader(this.path, this.splitter);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await getTextFromPdf(path);
    for (final content in splitter.splitText(text)) {
      yield Document(
        id: uuid.v4().toString(),
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }
}
