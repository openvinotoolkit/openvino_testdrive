import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:collection/collection.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/utils/block.dart';
import 'package:inference/pages/workflow/utils/hardpoint.dart';
import 'package:inference/pages/workflow/utils/line.dart';

class WorkflowBlockPainter {
  WorkflowBlock block;
  final PictureInfo? icon;

  final _nodeRadius = 5.0;

  WorkflowBlockPainter({required this.block, required this.icon});

  bool hitTest(Offset location) {
    return block.dimensions.inflate(10).contains(location);

  }

  void paint(Canvas canvas, Size size, Offset mousePosition) {
    final Paint paint = Paint()
      ..color = Color(0xFFF0F0F0)//Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(block.dimensions, const Radius.circular(4)), paint);

    drawName(canvas, size);
    drawType(canvas, size);
    drawIcon(canvas, size);
    if (hitTest(mousePosition)) {
      drawSelectableNodes(canvas, size, mousePosition);
    }

  }

  void drawSelectableNodes(Canvas canvas, Size size, Offset mousePosition) {
    final Paint strokePaint = Paint()
      ..color = Color(0xFF7000FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint highlightedPaint = Paint()
      ..color = Color(0xFF7000FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final Paint paint = Paint()
      ..color = Color(0xFFF0F0F0)//Colors.black
      ..style = PaintingStyle.fill;

    for (final hardpoint in block.hardpoints) {
      if ((hardpoint.position - mousePosition).distanceSquared < _nodeRadius * _nodeRadius) {
        canvas.drawCircle(hardpoint.position, _nodeRadius, highlightedPaint);
      } else {
        canvas.drawCircle(hardpoint.position, _nodeRadius, paint);
        canvas.drawCircle(hardpoint.position, _nodeRadius, strokePaint);
      }

    }

  }


  void drawType(Canvas canvas, Size size) {
    const textStyle = TextStyle(
        color: Color(0xFF616161),
        fontSize: 12,
      );

    final textPainter = TextPainter(
      text: TextSpan(
        text: block.type,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, block.dimensions.topLeft + Offset(32, 4));

  }

  void drawName(Canvas canvas, Size size) {
    const textStyle = TextStyle(
        color: Color(0xFF242424),
        fontSize: 14,
      );

    final textPainter = TextPainter(
      text: TextSpan(
        text: block.name,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, block.dimensions.topLeft + Offset(32, 20));
  }

  void drawIcon(Canvas canvas, Size size) {
    if (icon != null) {
      final position = block.dimensions.topLeft + const Offset(10, 16);
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.drawPicture(icon!.picture);
      canvas.restore();
    }
  }

  Routine? onTapDown(Offset localPosition) {
    for (final hardpoint in block.hardpoints) {
      if ((hardpoint.position - localPosition).distanceSquared < _nodeRadius * _nodeRadius) {
        print("starting routine for ${hardpoint.position}");
        return HardpointRoutine(block: block, hardpoint: hardpoint);
      }
    }
    return MoveBlockRoutine(block: block, offset: localPosition - block.dimensions.topLeft);
  }
}

class MoveBlockRoutine extends Routine {
  final WorkflowBlock block;
  final Offset offset;
  MoveBlockRoutine({required this.block, required this.offset});

  @override
  void handle() async {
    await for (final event in eventStream.stream) {
      if (event.eventType == RoutineEventType.mouseMove) {
        final dp = event.position - (block.dimensions.topLeft + offset);
        block.dimensions = block.dimensions.translate(dp.dx, dp.dy);
        //print(block.dimensions);
        event.repaint();
        //block.dimensions = block.dimensions.shift(dp);
      }
      if (event.eventType == RoutineEventType.mouseUp) {
        stop();
      }
    }
  }

}

class HardpointRoutine extends Routine {
  final WorkflowBlock block;
  final Hardpoint hardpoint;
  Hardpoint? current;
  HardpointRoutine({
      required this.block,
      required this.hardpoint,
  });

  @override
  void handle() async {
    await for (final event in eventStream.stream) {
      //print("Got event: $event ${event.eventType} in connectRoutine => ${event.position}");
      current = Hardpoint(position: event.position, direction: Axis.vertical);
      for (final block in event.state.blocks) {
        if (block != this.block) {
          if (block.hitTest(event.position)) {
            current = block.closestHardpoint(event.position);
          }
        }
      }


      event.repaint();

      if (event.eventType == RoutineEventType.mouseUp) {
        for (final target in event.state.blocks) {
          if (target != block) {
            if (target.hitTest(event.position)) {
              //print("New connection: ${block.dimensions.topLeft} to ${target.block.dimensions.topLeft}");
              final existingConnection = event.state.connections.firstWhereOrNull((connection) {
                  return connection.from == block && connection.to == target ||
                  connection.to == block && connection.from == target;

              });
              if (existingConnection == null) {
                event.updateState(event.state..connections.add(
                    WorkflowConnection(from: block, to: target)
                ));
              }
            }
          }
        }

        stop();
      }
    }
    //print("done handling");
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (current == null) {
      return;
    }
    final Paint paint = Paint()
      ..color = Color(0xFF7000FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final Paint arcPaint = Paint()
      ..color = Color(0xFF7000FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final line = Line.betweenTwoPoints(hardpoint.position, hardpoint.direction, current!.position, current!.direction);

    //canvas.drawArc(Rect.fromPoints(hardpoint.position, current!), 0, pi, false, arcPaint);
    for (final segment in line.segments) {
      canvas.drawLine(segment.from, segment.to, paint);
    }


  }
}
