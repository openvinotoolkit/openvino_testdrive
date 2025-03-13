
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/utils/line.dart';

class EditorEventState {
  bool isHovered = false;
}

class WorkflowNode {
  final Offset position;
  final double radius = 10;
  EditorEventState eventState = EditorEventState();

  WorkflowNode({required this.position});

  bool hitTest(Offset location) {
    return (location - position).distanceSquared < radius * radius;
  }

  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (eventState.isHovered) {
      paint.style = PaintingStyle.fill;
    }

    canvas.drawCircle(position, radius, paint);
  }

  Routine? onTapDown(Offset localPosition) {
    return ConnectRoutine(node: this);
  }
}

class ConnectRoutine extends Routine {
  final WorkflowNode node;
  Offset? current;
  ConnectRoutine({required this.node});

  @override
  void handle() async {
    await for (final event in eventStream.stream) {
      //print("Got event: $event ${event.eventType} in connectRoutine => ${event.position}");
      current = event.position;

      //highlight connection nodes
      for (final n in event.state.nodes) {
        if (n != node) {
          final hit = n.hitTest(event.position);
          n.eventState.isHovered = hit;
          if (hit) {
            current = n.position;
          }
          break;
        }
      }
      event.repaint();

      if (event.eventType == RoutineEventType.mouseUp) {
        for (final n in event.state.nodes) {
          if (n != node && n.hitTest(event.position)) {
            print("made connection!");
          }
          n.eventState.isHovered = false;
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
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;


    final line = Line.betweenTwoPoints(node.position, Axis.horizontal, current!, Axis.horizontal);
    for (final segment in line.segments) {
      canvas.drawLine(segment.from, segment.to, paint);
    }

  }
}
