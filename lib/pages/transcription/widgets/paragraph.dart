// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0


import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/theme_fluent.dart';
import '../utils/message.dart';

String formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  final minutes = duration.inMinutes;
  final seconds = totalSeconds % 60;

  final minutesString = '$minutes'.padLeft(2, '0');
  final secondsString = '$seconds'.padLeft(2, '0');
  return '$minutesString:$secondsString';
}

class Paragraph extends StatefulWidget {
  final Function(Duration)? onSeek;
  final Message message;
  final String? highlightedText;

  const Paragraph({super.key, required this.message, this.onSeek, this.highlightedText});

  @override
  State<Paragraph> createState() => _ParagraphState();
}

class _ParagraphState extends State<Paragraph> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    List<TextSpan> pieces = [];
    if (widget.highlightedText != null) {
      final pattern = RegExp(widget.highlightedText!, caseSensitive: false);
      final sections = widget.message.message.split(pattern);
      if (sections.isNotEmpty) {
        pieces.add(TextSpan(text: sections.first));
        for (int i = 1; i < sections.length; i++) {
          pieces.add(
            TextSpan(
              text: widget.highlightedText!,
              style: TextStyle(backgroundColor: theme.accentColor),
            )
          );
          pieces.add(TextSpan(text: sections[i]));
        }
      }
    } else {
      pieces.add(TextSpan(text: widget.message.message));
    }
    return MouseRegion(
      onEnter: (_) {
        setState(() => hover = true);
      },
      onExit: (_) {
        setState(() => hover = false);
      },
      child: GestureDetector(
        onTap: () {
          widget.onSeek?.call(widget.message.position);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Text(formatDuration(widget.message.position.inSeconds),
                  style: TextStyle(
                    fontSize: 9,
                    color: subtleTextColor.of(theme),
                  )
                )
              ),
              Container(
                decoration: BoxDecoration(
                  color: hover ? subtleTextColor.of(theme).withOpacity(0.3) : null,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: theme.inactiveColor
                    ),
                    children: pieces
                  )
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
