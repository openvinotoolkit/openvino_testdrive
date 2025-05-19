// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';

class Elevation extends StatelessWidget {
  const Elevation({super.key, required this.child, this.elevation = 0.0, this.shape = const RoundedRectangleBorder(), this.shadowColor, this.backgroundColor});

  final Widget child;
  final double elevation;
  final ShapeBorder shape;
  final Color? shadowColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return AnimatedContainer(
      duration: theme.mediumAnimationDuration,
      curve: theme.animationCurve,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: shape,
        shadows: [
          BoxShadow(
            color: (shadowColor ?? theme.shadowColor).withValues(alpha: 0.13),
            blurRadius: 0.9 * elevation,
            offset: Offset(0, 0.4 * elevation),
          ),
          BoxShadow(
            color: (shadowColor ?? theme.shadowColor).withValues(alpha: 0.11),
            blurRadius: 0.225 * elevation,
            offset: Offset(0, 0.085 * elevation),
          ),
        ],
      ),
      child: child,
    );
  }
}
