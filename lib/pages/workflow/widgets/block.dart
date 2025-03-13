import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/widgets/node.dart';

class WorkflowBlock {
  Rect dimensions;
  EditorEventState eventState = EditorEventState();
  PictureInfo? pictureInfo;

  WorkflowBlock({required this.dimensions}) {
    final svg = SvgPicture.asset("images/workflow/image.svg");
    vg.loadPicture(svg.bytesLoader, null).then((picture) {
      pictureInfo = picture;
    });
  }

  bool hitTest(Offset location) {
    return dimensions.contains(location);
  }

  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xFFF0F0F0)//Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(dimensions, const Radius.circular(4)), paint);

    drawName(canvas, size);
    drawType(canvas, size);
    drawIcon(canvas, size);

  }

  void drawType(Canvas canvas, Size size) {
    const textStyle = TextStyle(
        color: Color(0xFF616161),
        fontSize: 12,
      );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Input',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, dimensions.topLeft + Offset(32, 4));
  }

  void drawName(Canvas canvas, Size size) {
    const textStyle = TextStyle(
        color: Color(0xFF242424),
        fontSize: 14,
      );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Image',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, dimensions.topLeft + Offset(32, 20));
  }

  void drawIcon(Canvas canvas, Size size) {
    if (pictureInfo != null) {
      final position = dimensions.topLeft + const Offset(10, 16);
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.drawPicture(pictureInfo!.picture);
      canvas.restore();
    }
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
