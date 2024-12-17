// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/theme_fluent.dart';

class Badge extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const Badge({
    super.key,
    required this.text,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return AnimatedContainer(
      duration: theme.fastAnimationDuration,
      curve: theme.animationCurve,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? cosmos.lightest : darkCosmos,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(color: theme.brightness == Brightness.light ? darkCosmos : cosmos),
          ),
          const SizedBox(width: 8.0),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              child: Icon(
                FluentIcons.clear,
                size: 12.0,
                color: theme.brightness == Brightness.light ? darkCosmos : cosmos,
              ),
            ),
          ),
        ],
      ),
    );
  }
}