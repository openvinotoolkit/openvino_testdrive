// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/pages/workflow/routines/routine.dart';
import 'package:inference/pages/workflow/workflow_state.dart';

class EditorPainter extends CustomPainter {
  final Matrix4 matrix;
  final Routine? routine;
  final WorkflowState state;
  final Offset mousePosition;
  final dynamic inspectingElement;
  final Map<String, PictureInfo> icons;

  EditorPainter({
      required this.matrix,
      required this.state,
      required this.mousePosition,
      required this.icons,
      this.inspectingElement,
      this.routine,
  });


  @override
  void paint(Canvas canvas, Size size) {
    canvas.transform(matrix.storage);
    for (final block in state.blocks) {
      if (block.data == inspectingElement) {
        block.drawHighlight(canvas, size);
      }
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
