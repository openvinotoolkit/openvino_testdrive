// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:inference/providers/vlm_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AssistantMessage extends StatefulWidget {
  final Message message;
  const AssistantMessage(this.message, {super.key});

  @override
  _AssistantMessageState createState() => _AssistantMessageState();
}

class _AssistantMessageState extends State<AssistantMessage> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
        locale: locale.languageCode, decimalDigits: 0);
    final theme = FluentTheme.of(context);
    final backgroundColor = theme.brightness.isDark
     ? theme.scaffoldBackgroundColor
     : const Color(0xFFF5F5F5);

    return Consumer<VLMInferenceProvider>(builder: (context, inferenceProvider, child) =>
      Align(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: inferenceProvider.project!.thumbnailImage(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SelectionContainer.disabled(
                      child: Row(
                        children: [
                          Text(
                            inferenceProvider.project!.name,
                            style:  TextStyle(
                              color: subtleTextColor.of(theme),
                            ),
                          ),
                          if (widget.message.time != null) Text(
                            DateFormat(' | yyyy-MM-dd HH:mm:ss').format(widget.message.time!),
                            style:  TextStyle(
                              color: subtleTextColor.of(theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() { _hovering = true; }),
                    onExit: (_) => setState(() { _hovering = false; }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 502),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: MarkdownBody(
                              data: widget.message.message,
                              extensionSet: md.ExtensionSet(
                                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                                [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
                              ),
                            ),
                          ),
                        ),
                        if (_hovering)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SelectionContainer.disabled(
                              child: Row(
                                children: [
                                  // Commented out, as VLM pipeline in OV doesn't return the correct values in return value.
                                  // if (widget.message.metrics != null) Padding(
                                  //   padding: const EdgeInsets.only(right: 8),
                                  //   child: Tooltip(
                                  //     message: 'Time to first token',
                                  //     child: Text(
                                  //       'TTF: ${nf.format(widget.message.metrics!.ttft)}ms',
                                  //       style:  TextStyle(
                                  //         fontSize: 12,
                                  //         color: subtleTextColor.of(theme),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // if (widget.message.metrics != null) Padding(
                                  //   padding: const EdgeInsets.only(right: 8),
                                  //   child: Tooltip(
                                  //     message: 'Time per output token',
                                  //     child: Text(
                                  //       'TPOT: ${nf.format(widget.message.metrics!.tpot)}ms',
                                  //       style:  TextStyle(
                                  //         fontSize: 12,
                                  //         color: subtleTextColor.of(theme),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  if (widget.message.metrics != null) Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Tooltip(
                                      message: 'Generate total duration',
                                      child: Text(
                                        'Generate: ${nf.format(widget.message.metrics!.generate_time/1000)}s',
                                        style:  TextStyle(
                                          fontSize: 12,
                                          color: subtleTextColor.of(theme),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(FluentIcons.copy),
                                    onPressed: () async{
                                      await displayInfoBar(context, builder: (context, close) =>
                                        InfoBar(
                                          title: const Text('Copied to clipboard'),
                                          severity: InfoBarSeverity.info,
                                          action: IconButton(
                                            icon: const Icon(FluentIcons.clear),
                                            onPressed: close,
                                          ),
                                        ),
                                      );
                                      Clipboard.setData(ClipboardData(text: widget.message.message));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ) else const SizedBox(height: 34)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}