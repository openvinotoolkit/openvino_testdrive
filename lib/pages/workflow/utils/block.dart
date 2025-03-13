import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

class WorkflowBlock {
  Rect dimensions;
  String type;
  String name;

  WorkflowBlock({
      required this.dimensions,
      required this.type,
      required this.name,
  });

  factory WorkflowBlock.at({
      required Offset position,
      required String type,
      required String name,
    }) {
      final width = max(calculateBlockWidth(type), calculateBlockWidth(name));
      return WorkflowBlock(
        dimensions: Rect.fromLTWH(position.dx, position.dy, width, 44),
        name: name,
        type: type,
      );
  }


  static double calculateBlockWidth(String text) {
    const textStyle = TextStyle(
        color: Color(0xFF616161),
        fontSize: 12,
      );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.width + 50;
  }
}
