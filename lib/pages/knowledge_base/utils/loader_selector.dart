import 'dart:math';

import 'package:inference/langchain/loaders/html_loader.dart';
import 'package:inference/langchain/loaders/pdf_loader.dart';
import 'package:inference/langchain/loaders/text_loader.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';

class WindowTextSplitter extends CharacterTextSplitter {

  const WindowTextSplitter({super.chunkSize, super.chunkOverlap});

  @override
  List<String> splitText(final String text) {
    // First we naively split the large input into a bunch of smaller ones
    final List<String> data = [];
    for (int i = 0; i < text.length; i += chunkOverlap) {
      final content = text.substring(i, min(i + chunkSize, text.length));
      data.add(content);
    }
    return data;
  }
}

BaseDocumentLoader? loaderFromPath(String path) {
  final ext = extension(path);

  const splitter = WindowTextSplitter(chunkSize: 400, chunkOverlap: 200);
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
