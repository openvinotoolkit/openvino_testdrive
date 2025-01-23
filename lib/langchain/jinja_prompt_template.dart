// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:jinja/jinja.dart';
import 'package:langchain/langchain.dart';

final class JinjaPromptTemplate extends BaseChatPromptTemplate {
  final Template jinjaTemplate;

  final String bosToken;
  final String eosToken;
  final bool addGenerationPrompt = true;

  const JinjaPromptTemplate(this.jinjaTemplate, {
      required this.eosToken,
      required this.bosToken,
      required super.inputVariables,
  });

  factory JinjaPromptTemplate.fromTemplateConfig(Map<String, dynamic> chatTemplateConfig, [Set<String> inputVariables = const {}]) {
    final chatTemplate = chatTemplateConfig["chat_template"];
    final env = Environment();
    final template = env.fromString(chatTemplate);

    return JinjaPromptTemplate(template,
      eosToken: chatTemplateConfig["eos_token"],
      bosToken: chatTemplateConfig["bos_token"],
      inputVariables: inputVariables
    );
  }

  @override
  JinjaPromptTemplate copyWith({
    final Set<String>? inputVariables,
    final PartialValues? partialVariables,
    final List<ChatMessagePromptTemplate>? promptMessages,
  }) {
    throw UnimplementedError();
  }

  @override
  List<ChatMessage> formatMessages([final InputValues values = const {}]) {
    throw UnimplementedError(); // no need for this one with formatPrompt override
  }

  @override
  PromptValue formatPrompt(final InputValues values) {
    final messages =[
      {"role": "system", "content": "Answer the question based on some info:\n ${values['context']}"},
      {"role": "user", "content": values['question']},
    ];

    return PromptValue.string(jinjaTemplate.render(
      {
        "messages": messages,
        "eos_token": eosToken,
        "bos_token": bosToken,
        "add_generation_prompt": addGenerationPrompt,
      }
    ));
  }

  @override
  // TODO: implement type
  String get type => throw UnimplementedError();
}
