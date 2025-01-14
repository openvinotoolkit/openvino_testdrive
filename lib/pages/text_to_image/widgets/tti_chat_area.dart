// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/pages/text_to_image/providers/text_to_image_inference_provider.dart';
import 'package:inference/pages/text_to_image/widgets/tti_metrics_grid.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart';

class TTIChatArea extends StatefulWidget {
  const TTIChatArea({super.key});

  @override
  State<TTIChatArea> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<TTIChatArea> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool attachedToBottom = true;

  void jumpToBottom({offset = 0}) {
    if (_scrollController.hasClients) {
      _scrollController
          .jumpTo(_scrollController.position.maxScrollExtent + offset);
    }
  }

  void message(String message) async {
    if (message.isEmpty) {
      return;
    }
    final tti = provider();
    if (!tti.initialized) {
      return;
    }

    if (tti.response != null) {
      return;
    }
    _controller.text = "";
    jumpToBottom(offset: 110); //move to bottom including both
    tti.message(message);
  }

  TextToImageInferenceProvider provider() =>
      Provider.of<TextToImageInferenceProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        attachedToBottom = _scrollController.position.pixels + 0.001 >=
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TextToImageInferenceProvider>(
        builder: (context, inference, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attachedToBottom) {
          jumpToBottom();
        }
      });

      final theme = FluentTheme.of(context);
      final textColor = theme.typography.body?.color ?? Colors.black;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(builder: (context) {
            if (!inference.initialized) {
              return Expanded(
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/intel-loading.gif', width: 100),
                    const Text("Loading model...")
                  ],
                )),
              );
            }
            return Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Builder(builder: (context) {
                        if (inference.messages.isEmpty) {
                          return Center(
                              child: Text(
                                  "Type a message to ${inference.project?.name ?? "assistant"}"));
                        }
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            SingleChildScrollView(
                              controller: _scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(

                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: inference.messages.map((message) {
                                      switch (message.speaker) {
                                        case Speaker.user:
                                          return UserInputMessage(message);
                                        case Speaker.assistant:
                                          return GeneratedImageMessage(
                                              message,
                                              inference.project!
                                                  .thumbnailImage(),
                                              inference.project!.name);
                                      }
                                    }).toList()),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              child: Builder(builder: (context) {
                                if (attachedToBottom) {
                                  return Container();
                                }
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: SizedBox(
                                      width: 200,
                                      height: 40,
                                      // Adjusted height to match Fluent UI's button dimensions
                                      child: FilledButton(
                                        child: const Text("Jump to bottom"),
                                        onPressed: () {
                                          jumpToBottom();
                                          setState(() {
                                            attachedToBottom = true;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        );
                      }),
                    ),

                    // SizedBox(
                    //   height: 30,
                    //   child: Builder(
                    //     builder: (context) {
                    //       if (inference.interimResponse == null){
                    //         return Container();
                    //       }
                    //       return Center(
                    //         child: OutlinedButton.icon(
                    //           onPressed: () => inference.forceStop(),
                    //           icon: const Icon(Icons.stop),
                    //           label: const Text("Stop responding")
                    //         ),
                    //       );
                    //     }
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 45, right: 45, top: 10, bottom: 25),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  "images/clear.svg",
                                  width: 20,
                                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                                ),
                                onPressed: () => inference.reset(),
                              ),
                            ),
                            Expanded(
                              child: TextBox(
                                    maxLines: null,
                                    keyboardType: TextInputType.text,
                                    placeholder: "Ask me anything...",
                                    controller: _controller,
                                    onSubmitted: message,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    suffix: IconButton(
                                      icon: Icon(
                                        FluentIcons.send,
                                        color:
                                            (inference.interimResponse == null
                                                ? textColor
                                                : textColor.withOpacity(0.2)),
                                      ),
                                      onPressed: () =>
                                      inference.interimResponse != null ? null :
                                          message(_controller.text),
                                    ),
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class UserInputMessage extends StatelessWidget {
  final Message message;

  const UserInputMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: MessageWidget(
                          message: message.message,
                          innerPadding: 8,
                          isSender: true),
                    ),
                  ]))
        ],
      ),
    );
  }
}

class GeneratedImageMessage extends StatelessWidget {
  final Message message;
  final ImageProvider icon;
  final String name;

  const GeneratedImageMessage(this.message, this.icon, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    final smartImage = SmartImage(message: message);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Wrap content
        children: [
          Table(
            columnWidths: const {
              0: FixedColumnWidth(40), // Fixed width for the first column
              1: IntrinsicColumnWidth(), // Flexible width for the second column
              2: FixedColumnWidth(40), // Fixed width for the first column
            },
            children: [
              TableRow(children: [
                Container(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, top: 8.0, bottom: 8.0),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: subtleTextColor.of(theme),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox.shrink(),
              ]),
              TableRow(children: [
                RoundedPicture(
                  name: name,
                  icon: icon,
                ),
                if (message.imageContent?.imageData != null)
                  Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 20),
                      child: Align(
                          alignment: Alignment.centerLeft, // Align left
                          child: MessageWidget(
                            image: smartImage,
                            metrics: message.metrics,
                            innerPadding: 24.0,
                            isSender: false,
                          ))),
                ImageOptionsWidget(
                  image: smartImage,
                  metrics: message.metrics,
                ),
              ])
            ],
          ),
        ],
      ),
    );
  }
}

void showMetricsDialog(BuildContext context, TTIMetrics metrics) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      content: TTIMetricsGrid(metrics: metrics),
    ),
  );
}

class RoundedPicture extends StatelessWidget {
  final String name;
  final ImageProvider icon; // Icon widget provided

  const RoundedPicture({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: icon, // Adjust this to fit your `name` field
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String? message;
  final SmartImage? image;
  final TTIMetrics? metrics; // If not set, no copy-paste options.
  final double innerPadding;
  final bool isSender;

  const MessageWidget(
      {super.key,
      this.message,
      this.image,
      this.metrics,
      required this.innerPadding,
      required this.isSender});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final textColor = theme.typography.body?.color ?? Colors.black;

    void showContentDialog(BuildContext context) async {
      if (image?.hasClipboard() ?? false) {
        showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) => ContentDialog(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            content: image,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color:
            isSender ? userMessageColor.of(theme) : modelMessageColor.of(theme),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
          bottomLeft: Radius.circular(4.0),
          bottomRight: Radius.circular(4.0),
        ),
      ),
      padding: EdgeInsets.all(innerPadding),
      child: Column(children: [
        image != null
            ? Column(children: [
                // Changes cursor to hand on hover when there's a dialog that can be opened
                MouseRegion(
                    cursor: image?.hasClipboard() ?? false
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: GestureDetector(
                        onTap: () => showContentDialog(context),
                        // Opens dialog on click
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 256.0,
                              maxWidth: 256.0,
                            ),
                            child: image!))),
              ])
            : const SizedBox.shrink(),
        message != null
            ? SelectableText(
                message!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              )
            : const SizedBox.shrink(),
      ]),
    );
  }
}

class ImageOptionsWidget extends StatelessWidget {
  final SmartImage? image;
  final TTIMetrics? metrics;

  const ImageOptionsWidget({super.key, this.image, this.metrics});

  @override
  Widget build(BuildContext context) {
    bool hasClipboard = image?.hasClipboard() ?? false;
    bool hasMetrics = metrics != null;
    final textColor =
        FluentTheme.of(context).typography.body?.color ?? Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min, // Wrap content
      children: [
        Opacity(
            opacity: hasClipboard ? 1.0 : 0.25,
            child: IconButton(
              icon: SvgPicture.asset(
                "images/copy.svg",
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                width: 14,
                height: 14,
              ),
              onPressed: hasClipboard
                  ? () {
                      image?.copyToClipboard();
                    }
                  : null,
            )),
        Opacity(
          opacity: hasMetrics ? 1.0 : 0.25,
          child: IconButton(
            icon: SvgPicture.asset(
              "images/stats.svg",
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              width: 14,
              height: 14,
            ),
            // tooltip: "Show stats",
            onPressed: () {
              metrics != null ? showMetricsDialog(context, metrics!) : null;
            },
          ),
        ),
      ],
    );
  }
}

class SmartImage extends StatelessWidget {
  final Message message;

  const SmartImage({super.key, required this.message});

  void copyToClipboard() {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null || message.imageContent == null) {
      return; // Clipboard API is not supported on this platform.
    }
    final item = DataWriterItem();

    item.add(Formats.jpeg(message.imageContent!.imageData));
    clipboard.write([item]);
  }

  bool hasClipboard() {
    return message.allowedCopy;
  }

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      message.imageContent!.imageData,
      width: message.imageContent!.width.toDouble(),
      height: message.imageContent!.height.toDouble(),
      fit: message.imageContent!.boxFit,
    );
  }
}
