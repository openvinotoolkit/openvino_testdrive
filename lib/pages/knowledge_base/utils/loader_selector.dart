import 'package:inference/langchain/loaders/html_loader.dart';
import 'package:inference/langchain/loaders/pdf_loader.dart';
import 'package:inference/langchain/loaders/text_loader.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';

const windowSize = 400;

String defaultLoaderSelector(String path) {
  final ext = extension(path);
  if (ext == ".pdf") {
    return "PdfLoader";
  }

  if (ext == ".html") {
    return "HTMLLoader";
  }

  //if (ext == ".json") {
  //  return JsonLoader(path,)
  //}

  return "TextLoader";
}

BaseDocumentLoader loaderFromName(String name, String path) {
  switch (name) {
    case "PdfLoader":
      return PdfLoader(path, windowSize);
    case "HTMLLoader":
      return HTMLLoader(path, windowSize);
    case "TextLoader":
      return TextLoader(path, windowSize);
    default:
      throw Exception("Unknown loader name: $name");
  }

}
