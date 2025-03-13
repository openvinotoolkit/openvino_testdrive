import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/widgets/node.dart';

class WorkflowBlock {
  Rect dimensions;
  EditorEventState eventState = EditorEventState();

  WorkflowBlock({required this.dimensions});

  bool hitTest(Offset location) {
    return dimensions.contains(location);
  }

  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (eventState.isHovered) {
      paint.style = PaintingStyle.fill;
    }

    canvas.drawRect(dimensions, paint);
  }

  Routine? onTapDown(Offset localPosition) {
    //if ((localPosition - dimensions.topLeft)

    return MoveBlockRoutine(block: this, offset: localPosition - dimensions.topLeft);
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
        print(block.dimensions);
        event.repaint();
        //block.dimensions = block.dimensions.shift(dp);
      }
      if (event.eventType == RoutineEventType.mouseUp) {
        stop();
      }
    }
  }

}
