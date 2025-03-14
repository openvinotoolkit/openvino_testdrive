// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/utils/data.dart';
import 'package:inference/pages/workflow/widgets/block.dart';
import 'package:inference/pages/workflow/widgets/inspector.dart';
import 'package:inference/pages/workflow/workflow_state.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;


class WorkflowEditorPage extends StatefulWidget {
  const WorkflowEditorPage({super.key});

  @override
  State<WorkflowEditorPage> createState() => _WorkflowEditorPageState();
}

class _WorkflowEditorPageState extends State<WorkflowEditorPage> {

  Future<Map<String, PictureInfo>>? iconFetcher;

  Future<Map<String, PictureInfo>> fetchIcons(List<String> paths) async {
    final icons = await Future.wait(paths.map((path) async {
        return MapEntry<String, PictureInfo>(
          path,
          await vg.loadPicture(SvgPicture.asset(path).bytesLoader, null)
        );
    }));
    return Map.fromEntries(icons);
  }

  @override
  void initState() {
    super.initState();
    iconFetcher = fetchIcons([
       "images/workflow/image.svg" ,
       "images/workflow/clipboard.svg" ,
       "images/workflow/flowchart.svg" ,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: iconFetcher,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return WorkflowEditor(icons: snapshot.requireData);
        }
        return Container();
      }
    );
  }
}
class WorkflowEditor extends StatefulWidget {
  final Map<String, PictureInfo> icons;

  const WorkflowEditor({
      required this.icons,
      super.key,
  });

  @override
  State<WorkflowEditor> createState() => _WorkflowEditorState();
}

class _WorkflowEditorState extends State<WorkflowEditor> {
  final Matrix4 matrix = Matrix4.identity();
  final Matrix4 inverse = Matrix4.identity();
  WorkflowState state = WorkflowState();
  Routine? routine;
  Offset mousePosition = Offset.zero;

  WorkflowBlock? inspectingElement;

  void sendEvent(RoutineEventType type, Offset position) {
    routine?.sendEvent(RoutineEvent(
        state: state,
        eventType: type,
        position: position,
        repaint: repaint,
        updateState: updateState,
        setRoutine: setRoutine,
        inspect: inspect,
    ));
  }

  @override
  void initState() {
    super.initState();
    state.blocks.addAll([
       WorkflowBlockPainter(
         data: WorkflowBlock.at(position: Offset(500, 100), name: "Image", type: "Input"),
         icon: widget.icons["images/workflow/image.svg"]
       ),
       WorkflowBlockPainter(
          data: WorkflowBlock.at(position: Offset(200, 80), name: "Detection", type: "Processing"),
         icon: widget.icons["images/workflow/flowchart.svg"]
       ),
       WorkflowBlockPainter(
         data: WorkflowBlock.at(position: Offset(500, 300), name: "Crop", type: "Task"),
         icon: widget.icons["images/workflow/clipboard.svg"]
       ),
       WorkflowBlockPainter(
         data: WorkflowBlock.at(position: Offset(200, 300), name: "Classification", type: "Processing"),
         icon: widget.icons["images/workflow/flowchart.svg"]
       ),
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

  void updateState(WorkflowState newState) {
    setState(() {
        state = newState;
    });
  }

  void inspect(WorkflowBlock block) {
    setState(() {
      inspectingElement = block;
    });
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
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: MouseRegion(
              onHover: onHover,
              child: GestureDetector(
                onPanStart: onPanStart,
                onPanEnd: onPanEnd,
                onPanUpdate: pan,
                onTapDown: (details) => onTapDown(details.localPosition),
                onTapUp: (details) => onTapUp(details.localPosition),
                child: SizedBox.expand(
                  child: CustomPaint(
                    painter: EditorPainter(
                      matrix: matrix,
                      state: state,
                      routine: routine,
                      mousePosition: mousePosition,
                      icons: widget.icons,
                    ),
                  ),
                ),
              ),
            )
          ),
        ),
        Inspector(element: inspectingElement),
      ],
    );
  }
}

class EditorPainter extends CustomPainter {
  final Matrix4 matrix;
  final Routine? routine;
  final WorkflowState state;
  final Offset mousePosition;
  final Map<String, PictureInfo> icons;

  EditorPainter({
      required this.matrix,
      required this.state,
      required this.mousePosition,
      required this.icons,
      this.routine,
  });


  @override
  void paint(Canvas canvas, Size size) {
    canvas.transform(matrix.storage);
    for (final block in state.blocks) {
      block.paint(canvas, size, mousePosition);
    }

    for (final connection in state.connections) {
      connection.paint(canvas, size, mousePosition);
    }

    routine?.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant EditorPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) => true;
}
