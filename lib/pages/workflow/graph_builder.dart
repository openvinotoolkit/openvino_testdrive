 import 'package:inference/pages/workflow/blocks/block.dart';
import 'package:inference/pages/workflow/utils/data.dart';
import 'package:inference/pages/workflow/workflow_state.dart';

class GraphBuilder {
  final WorkflowState state;

  List<WorkflowConnection> get connections => state.connections.map((m) => m.data).toList();

  const GraphBuilder({
      required this.state,
  });

  void generate() {
    print("Generating");
    List<WorkflowBlockBase> inputs;

    for (final connection in connections) {
      print(connection.from);
      print(connection.to);
    }

  }

  WorkflowBlock? findRoot() {
    final connection = state.connections.first;
    List<WorkflowBlock> paths = [connection.data.from];
    //finds last root. Not proper implementation, but not using for now
    WorkflowBlock? last;

    while (paths.isNotEmpty) {
      final path = paths.removeLast();
      last = path;
      paths.addAll(
        findBlockInputConnections(path)
      );
    }

    print(last?.name);
  }

  List<WorkflowBlock> findBlockInputConnections(WorkflowBlock block) {
    final List<WorkflowBlock> blocks = [];
    for (final connection in state.connections) {
      if (connection.data.to == block) {
        blocks.add(connection.data.from);
      }
    }

    return blocks;
  }

 }
