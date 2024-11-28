import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
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
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(message.message,),
            ),
          )
        ],
      ),),
    );
  }
}