import 'package:inference/pages/workflow/widgets/block.dart';
import 'package:inference/pages/workflow/widgets/connection.dart';

class WorkflowState {
  final List<WorkflowBlockPainter> blocks = [];
  final List<WorkflowConnectionPainter> connections = [];

  Map<String, dynamic> toMap() {
    return {
      "blocks": blocks.map((b) => b.data.toMap()).toList(),
      "connections": connections.map((b) => b.data.toMap()).toList(),
    };
  }
}
