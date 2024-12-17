// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';

class ModelProperty extends StatelessWidget {
  final String name;
  final String value;

  const ModelProperty({
    super.key,
    required this.name,
    required this.value,
  });


  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final backgroundColor = theme.brightness.isDark
     ? theme.scaffoldBackgroundColor
     : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.apply(fontSizeDelta: -2),
              children: <TextSpan>[
                TextSpan(text: "$name: "),
                TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
