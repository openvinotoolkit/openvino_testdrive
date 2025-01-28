import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_pdf_reader/dart_pdf_reader.dart';


class PdfToTextParser {

  static final arrayTextInstructionMatcher = RegExp("\\/F\\d* ([\\d|\\.]*) Tf|\\[(.*?)\\]TJ", multiLine: true);
  static final octalMatcher = RegExp("\\\\(\\d{3})", multiLine: true);
  static final arrayTextStringMatcher = RegExp("(?<Offset>\\d*)\\((?<Text>.*?)\\)", multiLine: true);

  static String replaceOctals(String text) {
    return text.replaceAllMapped(octalMatcher, (match) {
      final octalValue = int.parse(match[1] ?? "0", radix: 8);
      return String.fromCharCode(octalValue);
    });
  }

  static String parsePageData(Uint8List bytes) {
    final streamText = utf8.decode(bytes);

    double fontSize = 1;
    String output = "";
    for (final match in arrayTextInstructionMatcher.allMatches(streamText)){
      if (match[1] != null) { //font setting
        fontSize = double.parse(match[1]!);
      }
      if (match[2] != null) {
        String piece = "";
        for (final m in arrayTextStringMatcher.allMatches(match[2]!)) {
          String? text = m.namedGroup('Text');
          final offset = m.namedGroup('Offset');
          if (offset != null && offset != "") {
            final spacing =  double.parse(offset);
            if (spacing * fontSize / 1000 > fontSize * 0.15) {
              piece += " ";
            }
          }
          if (text != null) {
            piece += replaceOctals(text);
          }
        }
        output += "$piece\n";
      }
    }

    return output;
  }

  static Future<String> convertPdfToText(String path) async {
    final stream = ByteStream(File(path).readAsBytesSync());
    final doc = await PDFParser(stream).parse();
    final catalog = await doc.catalog;
    final pages = await catalog.getPages();
    String output = "";
    for (int i =  0; i < pages.pageCount; i++) {
      print("page $i");
      final pages = await catalog.getPages(); // bit ugly, but contentStreams seems to be broken
      final streams = await pages.getPageAtIndex(i).contentStreams ?? [];
      if (streams.isNotEmpty) {
        final stream = streams.first;
        output += parsePageData(await stream.read(catalog.resolver));
      }
    }
    return output;
  }

}
