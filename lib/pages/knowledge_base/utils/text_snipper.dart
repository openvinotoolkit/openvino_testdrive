import 'dart:math';

class TextSnipper {
  final int windowSize;
  final int windowShift;


  const TextSnipper({required this.windowSize, required this.windowShift});

  List<String> snip(String text) {
    final List<String> data = [];
    for (int i = 0; i < text.length; i += windowShift) {
      final content = text.substring(i, min(i + windowSize, text.length));
      data.add(content);
    }
    return data;
  }
}
