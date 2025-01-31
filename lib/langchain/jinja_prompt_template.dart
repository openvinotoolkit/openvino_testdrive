// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:jinja/jinja.dart';
import 'package:langchain/langchain.dart';

const textGenerationTemplate = """
{% for message in messages %}{%- if message['role'] == 'system' %}{{message['content']}}

Question:
{%- endif %}{% endfor %}
{% for message in messages %}{%- if message['role'] == 'user' %}{{message['content']}}{%- endif %}{% endfor %}
""";

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
    final chatTemplate = chatTemplateConfig.containsKey("chat_template")
      ? chatTemplateConfig["chat_template"]
      : textGenerationTemplate;
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
    List<Map<String, dynamic>> messages = [];
    if (values.containsKey('history')) {
      for (final message in values['history']) {
        if (message is AIChatMessage) {
          messages.add({"role": "assistant", "content": message.contentAsString});
        }
        if (message is HumanChatMessage) {
          messages.add({"role": "user", "content": message.contentAsString});
        }
      }
    }
    if (values.containsKey('context') && values['context'] != "") {
      messages.add({"role": "system", "content": "Answer the question based on some info:\n ${values['context']}"});
    }
    if (values.containsKey('question')) {
      messages.add({"role": "user", "content": values['question']});
    }

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
