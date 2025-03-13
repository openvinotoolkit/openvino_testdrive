import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/utils/block.dart';
import 'package:inference/pages/workflow/utils/line.dart';

class WorkflowConnectionPainter {
  final WorkflowConnection data;

  final _nodeRadius = 5.0;

  const WorkflowConnectionPainter({
      required this.data,
  });

  void paint(Canvas canvas, Size size, Offset mousePosition) {
    final fromHardpoint = data.from.closestHardpoint(data.to.dimensions.center);
    final toHardpoint = data.to.closestHardpoint(data.from.dimensions.center);
    final line = Line.betweenTwoPoints(fromHardpoint.position, fromHardpoint.direction, toHardpoint.position, toHardpoint.direction);
    final Paint paint = Paint()
      ..color = Color(0xFF7000FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;


      canvas.drawCircle(fromHardpoint.position, _nodeRadius, paint);
      canvas.drawCircle(toHardpoint.position, _nodeRadius, paint);
    for (final segment in line.segments) {
      canvas.drawLine(segment.from, segment.to, paint);
    }
  }
}
