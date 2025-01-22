// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:inference/pages/text_to_image/widgets/assistant_message.dart';
import 'package:inference/pages/text_to_image/widgets/user_message.dart';
import 'package:inference/pages/text_to_image/widgets/model_properties.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/text_to_image_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/device_selector.dart';
import 'package:inference/widgets/toolbar_text_input.dart';
import 'package:provider/provider.dart';

class TTIPlayground extends StatefulWidget {
  final Project project;

  const TTIPlayground({required this.project, super.key});


  @override
  _TTIPlaygroundState createState() => _TTIPlaygroundState();
}

class SubmitMessageIntent extends Intent {}

class _TTIPlaygroundState extends State<TTIPlayground> {
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
    final provider = Provider.of<TextToImageInferenceProvider>(context, listen: false);
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
        Consumer<TextToImageInferenceProvider>(builder: (context, provider, child) =>
            Expanded(child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: GridContainer(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const DeviceSelector(),
                            const Divider(size: 24,direction: Axis.vertical,),
                            const SizedBox(width: 24,),
                            ToolbarTextInput(
                                marginLeft: 0,
                                labelText: "Width",
                                suffix: "px",
                                initialValue: provider.width,
                                roundPowerOfTwo: true,
                                onChanged: (value) { provider.width = value; }),
                            ToolbarTextInput(
                                marginLeft: 20,
                                labelText: "Height",
                                suffix: "px",
                                initialValue: provider.height,
                                roundPowerOfTwo: true,
                                onChanged: (value) { provider.height = value; }),
                            ToolbarTextInput(
                                marginLeft: 20,
                                labelText: "Rounds",
                                suffix: "",
                                initialValue: provider.rounds,
                                onChanged: (value) { provider.rounds = value; }),
                          ],
                        )
                    ),
                  ),
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
                            SizedBox(width: 64,height: 64, child: ProgressRing()),
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
                              return Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  SingleChildScrollView(
                                    controller: _scrollController,
                                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20), child: SelectionArea(
                                      child: SelectionArea(
                                        child: Column(
                                          children: provider.messages.map((message) { switch (message.speaker) {
                                            case Speaker.user: return Padding(
                                              padding: const EdgeInsets.only(left: 42),
                                              child: UserInputMessage(message),
                                            );
                                            case Speaker.system: return Text('System: ${message.message}');
                                            case Speaker.assistant: return GeneratedImageMessage(
                                                message,
                                                provider.project!
                                                    .thumbnailImage(),
                                                provider.project!.name);
                                          }}).toList(),
                                        ),
                                      ),
                                    ),),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    child: Builder(builder: (context) => attachedToBottom
                                        ? const SizedBox()
                                        : Padding(
                                      padding: const EdgeInsets.only(top:2),
                                      child: FilledButton(child: const Row(
                                        children: [
                                          Icon(FluentIcons.chevron_down, size: 12),
                                          SizedBox(width: 4),
                                          Text('Scroll to bottom'),
                                        ],
                                      ), onPressed: () {
                                        jumpToBottom();
                                        setState(() {
                                          attachedToBottom = true;
                                        });
                                      }),
                                    )
                                    ),
                                  )
                                ],
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
