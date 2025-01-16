import 'package:inference/langchain/loaders/html_loader.dart';
import 'package:inference/langchain/loaders/pdf_loader.dart';
import 'package:inference/langchain/loaders/text_loader.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';

const windowSize = 400;

BaseDocumentLoader? loaderFromPath(String path) {
  final ext = extension(path);
  switch (ext) {
    case ".pdf":
      return PdfLoader(path, windowSize);
    case ".html":
      return HTMLLoader(path, windowSize);
    case ".txt":
      return TextLoader(path, windowSize);
    default:
      return null;
  }
}
