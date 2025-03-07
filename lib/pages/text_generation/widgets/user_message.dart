// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:inference/pages/text_generation/utils/user_file.dart';
import 'package:inference/pages/text_generation/widgets/user_file_widget.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/theme_fluent.dart';

class UserMessage extends StatelessWidget {
  final Message message;
  const UserMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: cosmosBackground.of(theme),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MarkdownBody(
                data: message.message,
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                  [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                ),
              ),
            ),
          ),
          if (message.sources != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 5,
              children: [
                for (final source in message.sources!)
                  UserFileWidget(file: UserFile.fromPath(source))
              ],
            ),
          ),
        ],
      ),),
    );
  }
}
