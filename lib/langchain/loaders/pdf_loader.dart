import 'package:inference/interop/pdf_extractor.dart';
import 'package:inference/pages/knowledge_base/utils/text_snipper.dart';
import 'package:langchain/langchain.dart';
import 'package:uuid/uuid.dart';

class PdfLoader extends BaseDocumentLoader {

  final String path;
  final TextSnipper snipper;
  const PdfLoader(this.path, this.snipper);

  @override
  Stream<Document> lazyLoad() async* {
    const uuid = Uuid();

    final text = await getTextFromPdf(path);
    for (final content in snipper.snip(text)) {
      yield Document(
        id: uuid.v4().toString(),
        pageContent: content,
        metadata: {"source": path},
      );
    }
  }
}
