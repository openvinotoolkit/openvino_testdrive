import 'package:inference/langchain/loaders/html_loader.dart';
import 'package:inference/langchain/loaders/pdf_loader.dart';
import 'package:inference/langchain/loaders/text_loader.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';

BaseDocumentLoader? loaderFromPath(String path) {
  final ext = extension(path);

  const splitter = CharacterTextSplitter(chunkSize: 400, chunkOverlap: 200);
  switch (ext) {
    case ".pdf":
      return PdfLoader(path, splitter);
    case ".html":
      return HTMLLoader(path, splitter);
    case ".txt":
      return TextLoader(path, splitter);
    default:
      return null;
  }
}
