// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/text_generation/utils/user_file.dart';
import 'package:inference/theme_fluent.dart';

class UserFileWidget extends StatelessWidget {
  final Function? onDelete;
  final UserFile file;
  const UserFileWidget({super.key, required this.file, this.onDelete});

  final double iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    if (file.error == null) {
      return buildWidget(context);
    } else {
      return Tooltip(
        message: file.error,
        style: const TooltipThemeData(
          waitDuration: Duration(),
        ),
        child: buildWidget(context),
      );
    }
  }

  Widget buildWidget(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cosmosBackground.of(theme).withAlpha(150),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: file.error == null
            ? Colors.transparent
            : Colors.red
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.text_document, color: theme.inactiveColor, size: iconSize),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Text(file.filename),
            ),
            if (onDelete != null) IconButton(
              icon: const Icon(FluentIcons.clear, size: 8),
              onPressed: () => onDelete?.call(),
            )
          ],
        ),
      )
    );
  }
}
