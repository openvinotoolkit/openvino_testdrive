import 'package:inference/langchain/loaders/html_loader.dart';
import 'package:inference/langchain/loaders/pdf_loader.dart';
import 'package:inference/langchain/loaders/text_loader.dart';
import 'package:inference/pages/knowledge_base/utils/text_snipper.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';

BaseDocumentLoader? loaderFromPath(String path) {
  final ext = extension(path);
  const snipper = TextSnipper(windowSize: 400,  windowShift: 200);
  switch (ext) {
    case ".pdf":
      return PdfLoader(path, snipper);
    case ".html":
      return HTMLLoader(path, snipper);
    case ".txt":
      return TextLoader(path, snipper);
    default:
      return null;
  }
}
