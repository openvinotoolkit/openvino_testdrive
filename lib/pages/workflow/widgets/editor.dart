// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:inference/pages/workflow/blocks/crop.dart';
import 'package:inference/pages/workflow/blocks/image.dart';
import 'package:inference/pages/workflow/blocks/model.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/utils/assets.dart';
import 'package:inference/pages/workflow/utils/data.dart';
import 'package:inference/pages/workflow/widgets/block.dart';
import 'package:inference/pages/workflow/widgets/editor_painter.dart';
import 'package:inference/pages/workflow/widgets/inspector.dart';
import 'package:inference/pages/workflow/workflow_state.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class WorkflowEditor extends StatefulWidget {
  final WorkflowEditorAssets assets;

  get icons => assets.icons;
  get models => assets.models;

  const WorkflowEditor({
      required this.assets,
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
         data: WorkflowBlock.at(position: Offset(500, 100), name: "Image", type: ImageBlock()),
         icon: widget.icons["images/workflow/image.svg"]
       ),
       WorkflowBlockPainter(
          data: WorkflowBlock.at(position: Offset(200, 80), name: "Detection", type: ModelBlock()),
         icon: widget.icons["images/workflow/flowchart.svg"]
       ),
       WorkflowBlockPainter(
         data: WorkflowBlock.at(position: Offset(500, 300), name: "Crop", type: CropBlock()),
         icon: widget.icons["images/workflow/clipboard.svg"]
       ),
       WorkflowBlockPainter(
         data: WorkflowBlock.at(position: Offset(200, 300), name: "Classification", type: ModelBlock()),
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
    final theme = FluentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridContainer(
          color: backgroundColor.of(theme),
          padding: const EdgeInsets.all(16),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Workflows",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GridContainer(
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
                            inspectingElement: inspectingElement,
                            icons: widget.icons,
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              ),
              GridContainer(
                child: Inspector(
                  element: inspectingElement,
                  models: widget.models,
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}
