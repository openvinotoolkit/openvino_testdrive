import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/utils/hardpoint.dart';

class WorkflowBlock {
  Rect dimensions;
  String type;
  String name;

  WorkflowBlock({
      required this.dimensions,
      required this.type,
      required this.name,
  });

  bool hitTest(Offset location) {
    return dimensions.inflate(10).contains(location);
  }

  List<Hardpoint> get hardpoints => [
    Hardpoint(position: dimensions.centerLeft, direction: Axis.horizontal),
    Hardpoint(position: dimensions.topCenter, direction: Axis.vertical),
    Hardpoint(position: dimensions.bottomCenter, direction: Axis.vertical),
    Hardpoint(position: dimensions.centerRight, direction: Axis.horizontal),
  ];

  Hardpoint closestHardpoint(Offset position) {
    List<MapEntry<Hardpoint, double>> points = hardpoints.map((p) {
        return MapEntry(p, (p.position - position).distanceSquared);
    }).toList();

    points.sort((a, b) => a.value.compareTo(b.value));
    return points.first.key;
  }


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

class WorkflowConnection {
  final WorkflowBlock from;
  final WorkflowBlock to;

  const WorkflowConnection({
      required this.from,
      required this.to,
  });
}
