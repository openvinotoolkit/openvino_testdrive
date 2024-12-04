import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/annotation.dart';
import 'package:inference/widgets/canvas/canvas_painter.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:inference/project.dart' as project;

class Canvas extends StatefulWidget {

  final ui.Image image;
  final List<Annotation>? annotations;
  final List<project.Label> labelDefinitions;

  const Canvas({required this.image, this.annotations, required this.labelDefinitions, super.key});

  @override
  State<Canvas> createState() => _CanvasState();
}

class _CanvasState extends State<Canvas> {

  double prevScale = 1;
  Matrix4 matrix = Matrix4.identity()
    ..scale(0.9);
  Matrix4 inverse = Matrix4.identity();
  bool done = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) {
      setState(() {
          matrix = setTransformToFit(widget.image);
      });
    });
  }

  Matrix4 setTransformToFit(ui.Image image) {
    if (context.size == null) {
      return Matrix4.identity();
    }
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final canvasSize = context.size!;

    final ratio = Size(imageSize.width / canvasSize.width, imageSize.height / canvasSize.height);

    final scale = 1 / max(ratio.width, ratio.height) * 0.9;
    final offset = (canvasSize - imageSize * scale as Offset) / 2;

    return matrix = Matrix4.identity()
      ..translate(offset.dx, offset.dy, 0.0)
      ..scale(scale);
  }

  void scaleCanvas(Vector3 localPosition, double scale) {
      inverse.copyInverse(matrix);
      final position = inverse * localPosition;
      final mScale = 1 - scale;
      setState(() {
          matrix *= Matrix4( // row major or column major
              scale, 0, 0, 0,
              0, scale, 0, 0,
              0, 0, scale, 0,
              mScale * position.x, mScale * position.y, 0, 1);
      });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (f) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            matrix = setTransformToFit(widget.image);
          });
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: SizedBox.expand(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(shape: BoxShape.rectangle),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onScaleStart: (_) {
                prevScale = 1;
              },
              onDoubleTap: () {
                setState(() {
                  matrix = setTransformToFit(widget.image);
                });
              },
              onScaleUpdate: (ScaleUpdateDetails d) {
                final scale = 1 - (prevScale - d.scale);
                prevScale = d.scale;
                final zoom = matrix.getMaxScaleOnAxis();
                scaleCanvas(Vector3(d.localFocalPoint.dx, d.localFocalPoint.dy, 0), scale);
                setState(() {
                    matrix.translate(d.focalPointDelta.dx / zoom, d.focalPointDelta.dy / zoom, 0.0);
                });
              },
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerSignal: (p) {
                  if (p is PointerScrollEvent) {
                    final scale = p.scrollDelta.dy > 0 ? 0.95 : 1.05; // lazy solution, perhaps an animation depending on the scrollDelta?
                    scaleCanvas(Vector3(p.localPosition.dx, p.localPosition.dy, 0.0), scale);
                  }
                },
                child: Transform(
                  transform: matrix,
                  alignment: FractionalOffset.topLeft,
                  child: Builder(
                    builder: (context) {
                      return CustomPaint(
                        painter: CanvasPainter(widget.image, widget.annotations, widget.labelDefinitions, matrix.getMaxScaleOnAxis()),
                        child: Container(),
                      );
                    }
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
