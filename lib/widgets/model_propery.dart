// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/theme_fluent.dart';

class ModelProperty extends StatelessWidget {
  final String title;
  final String value;
  final String? description;

  const ModelProperty({
      super.key,
      required this.title,
      required this.value,
      this.description,
    });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            )),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: description!,
                child: Icon(
                  FluentIcons.info,
                  size: 16,
                  color: subtleTextColor.of(theme),
                ),
              ),
            ],
          ],),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(value, style: TextStyle(
              fontSize: 16,
              color: subtleTextColor.of(theme),
          )),
        ),
      ]
    );
  }
}