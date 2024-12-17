// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/theme_fluent.dart';

class GridContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final Color? color;
  final bool? borderTop;
  final bool? borderLeft;
  final BorderRadiusGeometry? borderRadius;

  const GridContainer({super.key, this.child, this.padding, this.color, this.borderTop, this.borderLeft, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
        border: Border(
          top: borderTop == false ? BorderSide.none : BorderSide(
            color: borderColor.of(theme),
            width: 1,
          ),
          left: borderLeft == false ? BorderSide.none : BorderSide(
            color: borderColor.of(theme),
            width: 1,
          ),
        )
      ),
      child: child
    );
  }

}
