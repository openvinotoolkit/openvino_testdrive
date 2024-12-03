import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inference/annotation.dart';
import 'package:inference/color.dart';
import 'package:inference/project.dart' as project;
import 'package:vector_math/vector_math_64.dart' show Vector3;

Color getColorByLabelID(String labelId, List<project.Label> labelDefinitions) {
  final label = labelDefinitions.firstWhereOrNull((project.Label b) => b.id == labelId);
  if (label == null) {
    throw "Label not found";
  }
  return HexColor.fromHex(label.color.substring(0, 7));
}

class CanvasPainter extends CustomPainter {
  final ui.Image image;
  final List<Annotation>? annotations;
  final List<project.Label> labelDefinitions;
  final double scale;

  CanvasPainter(this.image, this.annotations, this.labelDefinitions, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      alignment: Alignment.topLeft,
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      fit: BoxFit.scaleDown,
      image: image,
    );
    for (final annotation in annotations ?? []) {
      final firstLabelColor = getColorByLabelID(annotation.labels[0].id, labelDefinitions);
      Paint paint = Paint()
        ..color = firstLabelColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      Paint transparent = Paint()
        ..color = Color.fromARGB(102, firstLabelColor.red, firstLabelColor.green, firstLabelColor.blue);

      if (annotation.shape is Rectangle) {
        drawRectangle(canvas, size, paint, transparent, annotation);
      }
      if (annotation.shape is Polygon) {
        drawPolygon(canvas, size, paint, transparent, annotation);
      }
      if (annotation.shape is RotatedRectangle) {
        drawRotatedRectangle(canvas, size, paint, transparent, annotation);
      }
    }
  }

  void drawRectangle(Canvas canvas, Size size, Paint paint, Paint transparent, Annotation annotation){
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final rect = (annotation.shape as Rectangle).toRect();
    canvas.drawRect(rect, paint);
    if (rect.size != imageSize) {
      canvas.drawRect(rect, transparent);
    }
    var position = rect.topLeft;
    for (final label in annotation.labels) {
      final labelSize = drawLabel(canvas, size, label, position);
      position += Offset(labelSize.width, 0);
    }
  }


  void drawPolygon(Canvas canvas, Size size, Paint paint, Paint transparent, Annotation annotation) {
    final path = ui.Path();
    final shape = (annotation.shape as Polygon);
    path.addPolygon(shape.points, true);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, transparent);
    final rect = shape.rectangle.toRect();
    final topCenter = rect.topCenter - const Offset(0, 30.0);
    canvas.drawLine(rect.center, topCenter, paint);

    var position = topCenter;
    for (final label in annotation.labels) {
      final labelSize = drawLabel(canvas, size, label, position);
      position += Offset(labelSize.width, 0);
    }
  }

  void drawRotatedRectangle(Canvas canvas, Size size, Paint paint, Paint transparent, Annotation annotation) {
    final shape = (annotation.shape as RotatedRectangle);
    final path = ui.Path();
    final rect = ui.Rect.fromCenter(center: ui.Offset.zero, width: shape.width, height: shape.height);
    path.addRect(rect);
    final matrix = Matrix4.identity()
      ..rotateZ(shape.angleInRadians)
      ..setTranslationRaw(shape.centerX, shape.centerY, 0.0);

    final corners = [rect.topLeft, rect.topRight, rect.bottomRight, rect. bottomLeft];



    final rotatedPath = path.transform(matrix.storage);
    canvas.drawPath(rotatedPath, paint);
    canvas.drawPath(rotatedPath, transparent);

    double labelPosition = double.infinity;
    for (final corner in corners) {
      final transformedCorner = (matrix * Vector3(corner.dx, corner.dy, 0)) as Vector3;
      labelPosition = min(transformedCorner.y, labelPosition);
    }

    var position = Offset(shape.centerX, labelPosition - 30);
    canvas.drawLine(Offset(shape.centerX, shape.centerY), position, paint);
    for (final label in annotation.labels) {
      final labelSize = drawLabel(canvas, size, label, position);
      position += Offset(labelSize.width, 0);
    }
  }

  Size drawLabel(Canvas canvas, Size size, Label label, Offset position) {
    final color = getColorByLabelID(label.id, labelDefinitions);
    Paint paint = Paint()
      ..color = color;
    final textStyle = TextStyle(
      color: foregroundColorByLuminance(color),
      fontFamily: 'IntelOne',
      fontSize: 14 / scale,
    );
    final textSpan = TextSpan(
      text: "${label.name} ${(label.probability * 100).toStringAsFixed(1)}%",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    canvas.drawRect(ui.Rect.fromLTWH(position.dx - 1, position.dy - textPainter.height - 1, textPainter.width + 2, textPainter.height), paint);
    textPainter.paint(canvas, position - Offset(0, textPainter.height));
    return textPainter.size + const Offset(3, 0);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return false;
  }
  @override
  bool shouldRebuildSemantics(CanvasPainter oldDelegate) => false;
}
