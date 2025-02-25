// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:inference/pages/knowledge_base/utils/loader_selector.dart';
import 'package:inference/pages/text_generation/utils/user_file.dart';
import 'package:inference/pages/text_generation/widgets/user_file_widget.dart';
import 'package:inference/pages/text_generation/widgets/llm_options.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/pages/text_generation/widgets/assistant_message.dart';
import 'package:inference/pages/text_generation/widgets/model_properties.dart';
import 'package:inference/pages/text_generation/widgets/user_message.dart';
import 'package:inference/pages/text_generation/widgets/knowledge_base_selector.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/device_selector.dart';
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
  final List<UserFile> newFiles = [];
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

    final validFiles = newFiles.where((f) => f.error == null).toList();
    provider.message(message, validFiles);
    newFiles.clear();
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

  Future<void> selectDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: supportedExtensions);
    if (result != null) {
      for (final file in result.files) {
        final path = file.path!;
        UserFile userFile = UserFile.fromPath(path);
        final loader = loaderFromPath(path);
        if (loader == null) {
          userFile.error = "File type '${userFile.kind}' is not supported.";
        } else {
          userFile.documents = await loader.load();
        }
        setState(() {
          newFiles.add(userFile);
        });
      }
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
                      child: Row(
                        children: [
                          DeviceSelector(),
                          KnowledgeBaseSelector(),
                        ]
                      )
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
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final file in newFiles)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: UserFileWidget(
                                      file: file,
                                      onDelete: () {
                                        setState(() => newFiles.remove(file));
                                      }
                                    ),
                                  )
                              ]
                            ),
                          ),
                        )
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 20),
                                  child: Tooltip(
                                    message: "Add document",
                                    child: Button(
                                      onPressed: provider.interimResponse == null ? () => selectDocument() : null,
                                      child: const Icon(FluentIcons.attach, size: 18),
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
                                  child: Builder(builder: (context) => provider.interimResponse != null
                                    ? Tooltip(
                                      message: "Stop",
                                      child: Button(child: const Icon(FluentIcons.stop, size: 18,), onPressed: () { provider.forceStop(); }),
                                    )
                                    : Tooltip(
                                      message: "Send message",
                                      child: Button(child: const Icon(FluentIcons.send, size: 18,), onPressed: () { message(_textController.text); }),
                                    )
                                  ),
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
