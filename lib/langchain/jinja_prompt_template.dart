// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:jinja/jinja.dart';
import 'package:langchain/langchain.dart';

final class JinjaPromptTemplate extends BaseChatPromptTemplate {
  final Template jinjaTemplate;

  final String eosToken = "</s>"; //TODO: Remove hardcoded
  final bool addGenerationPrompt = true; //TODO: Remove hardcoded

  const JinjaPromptTemplate(this.jinjaTemplate, {required super.inputVariables});

  factory JinjaPromptTemplate.fromTemplate(String chatTemplate, [Set<String> inputVariables = const {}]) {
    final env = Environment();
    final template = env.fromString(chatTemplate);

    return JinjaPromptTemplate(template, inputVariables: inputVariables);
  }

  @override
  JinjaPromptTemplate copyWith({
    final Set<String>? inputVariables,
    final PartialValues? partialVariables,
    final List<ChatMessagePromptTemplate>? promptMessages,
  }) {
    throw UnimplementedError();
    //return JinjaPromptTemplate(
    //  inputVariables: inputVariables ?? this.inputVariables,
    //  partialVariables: partialVariables ?? this.partialVariables,
    //  promptMessages: promptMessages ?? this.promptMessages,
    //);
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
        "add_generation_prompt": addGenerationPrompt,
      }
    ));
  }

  @override
  // TODO: implement type
  String get type => throw UnimplementedError();
}
