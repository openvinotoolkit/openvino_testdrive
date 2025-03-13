// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/utils/block.dart';
import 'package:inference/pages/workflow/widgets/block.dart';
import 'package:inference/pages/workflow/workflow_state.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class WorkflowPage extends StatefulWidget {

  const WorkflowPage({super.key});

  @override
  State<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends State<WorkflowPage> {
  final Matrix4 matrix = Matrix4.identity();
  final Matrix4 inverse = Matrix4.identity();
  final WorkflowState state = WorkflowState();
  Routine? routine;
  Offset mousePosition = Offset.zero;

  void sendEvent(RoutineEventType type, Offset position) {
    routine?.sendEvent(RoutineEvent(
        state: state,
        eventType: type,
        position: position,
        repaint: repaint
    ));
  }

  @override
  void initState() {
    super.initState();
    state.blocks.addAll([
       WorkflowBlockPainter(block: WorkflowBlock.at(position: Offset(500, 100), name: "Input", type: "Image")),
       WorkflowBlockPainter(block: WorkflowBlock.at(position: Offset(200, 80), name: "Processing", type: "Detection")),
    ]);
  }

  void pan(DragUpdateDetails details) {
    final localPosition = screenToLocalPosition(details.localPosition);
    sendEvent(RoutineEventType.mouseMove, localPosition);

    setState(() {
      mousePosition = localPosition;
      if (routine == null) {
          matrix.translate(details.delta.dx, details.delta.dy);
          inverse.copyInverse(matrix);
      }
    });
  }

  void onHover(PointerHoverEvent details) {
    final localPosition = screenToLocalPosition(details.localPosition);
    sendEvent(RoutineEventType.mouseMove, localPosition);

    setState(() {
        mousePosition = localPosition;
    });
  }

  Offset screenToLocalPosition(Offset position) {
    final vec = Vector3(position.dx, position.dy, 0);
    Vector3 localPosition = inverse * vec;
    return Offset(localPosition.x, localPosition.y);
  }

  void onPanStart(DragStartDetails details) {
    onTapDown(details.localPosition);

    final localPosition = screenToLocalPosition(details.localPosition);
    sendEvent(RoutineEventType.mouseDown, localPosition);
  }
  void onPanEnd(DragEndDetails details) {
    final localPosition = screenToLocalPosition(details.localPosition);
    sendEvent(RoutineEventType.mouseUp, localPosition);
  }

  void repaint() {
    if (mounted) {
      setState(() {});
    }
  }

  bool setRoutine(Routine? newRoutine) {
    if (newRoutine == null || routine != null) {
      return false;
    }
    newRoutine.eventStream.onCancel = () {
      print(" on cancel");
      setState(() => routine = null);
    };
    setState(() {
      routine = newRoutine;
    });

    return true;
  }


  void onTapUp(Offset position) {
    final localPosition = screenToLocalPosition(position);
    sendEvent(RoutineEventType.mouseUp, localPosition);
  }

  void onTapDown(Offset position) {
    final localPosition = screenToLocalPosition(position);

    if (routine == null) {
      for (final block in state.blocks) {
        if (block.hitTest(localPosition)) {
          if (setRoutine(block.onTapDown(localPosition))) {
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: MouseRegion(
        onHover: onHover,
        child: GestureDetector(
          onPanStart: onPanStart,
          onPanEnd: onPanEnd,
          onPanUpdate: pan,
          onTapDown: (details) => onTapDown(details.localPosition),
          onTapUp: (details) => onTapUp(details.localPosition),
          child: CustomPaint(
            painter: EditorPainter(
              matrix: matrix,
              state: state,
              routine: routine,
              mousePosition: mousePosition,
            ),
          ),
        ),
      )
    );
  }


}

class EditorPainter extends CustomPainter {
  final Matrix4 matrix;
  final Routine? routine;
  final WorkflowState state;
  final Offset mousePosition;

  EditorPainter({
      required this.matrix,
      required this.state,
      required this.mousePosition,
      this.routine,
  });


  @override
  void paint(Canvas canvas, Size size) {
    canvas.transform(matrix.storage);
    for (final block in state.blocks) {
      block.paint(canvas, size, mousePosition);
    }

    routine?.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant EditorPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => true;
}
