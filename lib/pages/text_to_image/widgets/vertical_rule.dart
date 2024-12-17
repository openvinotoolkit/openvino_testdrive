// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/theme_fluent.dart';

class VerticalRule extends StatelessWidget {
  const VerticalRule({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: borderColor.of(theme),
              width: 1,
            )
          )
        ),
      ),
    );
  }
}
