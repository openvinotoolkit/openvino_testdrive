// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:inference/pages/text_generation/widgets/llm_options.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/pages/text_generation/widgets/assistant_message.dart';
import 'package:inference/pages/text_generation/widgets/model_properties.dart';
import 'package:inference/pages/text_generation/widgets/user_message.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/device_selector.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Playground extends StatefulWidget {
  final Project project;

  const Playground({required this.project, super.key});


  @override
  _PlaygroundState createState() => _PlaygroundState();
}

class SubmitMessageIntent extends Intent {}

class _PlaygroundState extends State<Playground> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool attachedToBottom = true;

  void jumpToBottom({ offset = 0 }) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + offset);
    }
  }

  void message(String message) {
    if (message.isEmpty) return;
    final provider = Provider.of<TextInferenceProvider>(context, listen: false);
    if (!provider.initialized || provider.response != null) return;
    _textController.text = '';
    jumpToBottom(offset: 110); //move to bottom including both
    provider.message(message).catchError((e) async {
      if (mounted) {
        await displayInfoBar(context, builder: (context, close) => InfoBar(
          title: const Text("An error occurred processing the message"),
          content: Text(e.toString()),
          severity: InfoBarSeverity.error,
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
        ));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        attachedToBottom = _scrollController.position.pixels + 0.001 >= _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (attachedToBottom) {
      jumpToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<TextInferenceProvider>(builder: (context, provider, child) =>
          Expanded(child: Column(
            children: [
              Expander(
                headerShape: (_) => const RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.zero,
                ),
                contentShape: (_) => const RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.zero,
                ),
                icon: const Row(
                  children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text("Options"),
                      ),
                      Icon(FluentIcons.settings),
                  ]
                ),
                header: const SizedBox(
                  height: 64,
                  child: GridContainer(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: DeviceSelector()
                      ),
                  ),
                ),
                content: LLMOptions(provider),
              ),
             Expanded(child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.brightness.isDark ? backgroundColor.dark : theme.scaffoldBackgroundColor
                ),
                child: GridContainer(child: SizedBox(
                  width: double.infinity,
                  child: Builder(builder: (context) {
                    if (!provider.initialized) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: ProgressRing()
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 18),
                            child: Text("Loading model..."),
                          )
                        ],
                      );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: Builder(builder: (context) {
                          if (provider.messages.isEmpty) {
                            return Center(
                              child: Text("Start chatting with ${provider.project?.name ?? "the model"}!"),
                            );
                          }
                          return SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
                              child: SelectionArea(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: provider.messages.map((message) => switch (message.speaker) {
                                    Speaker.user => Padding(
                                      padding: const EdgeInsets.only(left: 42),
                                      child: UserMessage(message),
                                    ),
                                    Speaker.system => Text('System: ${message.message}'),
                                    Speaker.assistant => AssistantMessage(message)
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Tooltip(
                                    message: "Create new thread",
                                    child: Button(
                                      onPressed: provider.interimResponse == null ? () => provider.reset() : null,
                                      child: const Icon(FluentIcons.rocket, size: 18),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Shortcuts(
                                        shortcuts: <LogicalKeySet, Intent>{
                                          LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter): SubmitMessageIntent(),
                                          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter): SubmitMessageIntent(),
                                        },
                                        child: Actions(
                                          actions: <Type, Action<Intent>>{
                                            SubmitMessageIntent: CallbackAction<SubmitMessageIntent>(
                                              onInvoke: (SubmitMessageIntent intent) => message(_textController.text),
                                            ),
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextBox(
                                                placeholder: "Type a message...",
                                                keyboardType: TextInputType.multiline,
                                                controller: _textController,
                                                maxLines: null,
                                                expands: true,
                                                onSubmitted: message,
                                                autofocus: true,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6, left: 10),
                                                child: Text(
                                                  'Press ${Platform.isMacOS ? '⌘' : 'Ctrl'} + Enter to submit, Enter for newline',
                                                  style: TextStyle(fontSize: 11, color: subtleTextColor.of(theme)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Builder(builder: (context) {
                                    final isRunning = provider.interimResponse != null;
                                    return Tooltip(
                                      message: "Send message",
                                      child: Button(
                                        onPressed: isRunning ?  null : () => message(_textController.text),
                                        child: const Icon(FluentIcons.send, size: 18),
                                      ),
                                    );
                                  }),
                                )
                              ]
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }),
               )),
             )),
          ],
        ))),
        const ModelProperties(),
      ],
    );
  }
}
