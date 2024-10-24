
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/config.dart';
import 'package:inference/hint.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/inference/textToImage/tti_metric_widgets.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/providers/text_to_image_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart';

class TTIPlayground extends StatefulWidget {
  const TTIPlayground({super.key});

  @override
  State<TTIPlayground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<TTIPlayground> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool attachedToBottom = true;

  void jumpToBottom({ offset = 0 }) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + offset);
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

  TextToImageInferenceProvider provider() => Provider.of<TextToImageInferenceProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
        setState(() {
          attachedToBottom = _scrollController.position.pixels + 0.001  >= _scrollController.position.maxScrollExtent;
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
    return Consumer<TextToImageInferenceProvider>(builder: (context, inference, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (attachedToBottom) {
            jumpToBottom();
          }
        });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DeviceSelector(),
                Hint(hint: HintsEnum.intelCoreLLMPerformanceSuggestion),
              ]
            ),
          ),
          Builder(
            builder: (context) {
              if (!inference.initialized){
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/intel-loading.gif', width: 100),
                        const Text("Loading model...")
                      ],
                    )
                  ),
                );
              }
              return Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: intelGray,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Builder(builder: (context) {
                          if (inference.messages.isEmpty) {
                            return Center(
                                child: Text("Type a message to ${inference.project?.name ?? "assistant"}"));
                          }
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              SingleChildScrollView(
                                controller: _scrollController,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: inference.messages.map((message) {
                                        switch (message.speaker) {
                                          case Speaker.user:
                                            return UserInputMessage(message);
                                          case Speaker.assistant:
                                            return GeneratedImageMessage(message, inference.project!.name);
                                        }
                                      }).toList()),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                child: Builder(
                                  builder: (context) {
                                    if (attachedToBottom) {
                                      return Container();
                                    }
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: SizedBox(
                                          width: 200,
                                          height: 20,
                                          child: FloatingActionButton(
                                            backgroundColor: intelGray,
                                            child: const Text("Jump to bottom"),
                                            onPressed: () {
                                              jumpToBottom();
                                              setState(() {
                                                attachedToBottom = true;
                                              });
                                            }
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                ),
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
                        padding: const EdgeInsets.only(left: 45, right: 45, top: 10, bottom: 25),
                        child: SizedBox(
                          height: 40,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  icon: SvgPicture.asset("images/clear.svg",
                                    colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
                                    width: 20,
                                  ),
                                  tooltip: "Clear chat",
                                  onPressed: () => inference.reset(),
                                  style: IconButton.styleFrom(
                                    backgroundColor: intelGrayReallyDark,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      side: BorderSide(
                                        color: intelGrayLight,
                                        width: 2,
                                      )
                                    )
                                  )
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  maxLines: null,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    hintText: "Ask me anything...",
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.send, color: (inference.interimResponse == null ? Colors.white : intelGray)),
                                      onPressed: () => message(_controller.text),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                        color: intelGrayLight,
                                        width: 2,
                                      )
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  controller: _controller,
                                  onSubmitted: message,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NameRowWidget(name: "You", icon: SvgPicture.asset("images/user.svg",
              colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
              width: 20,
            ),
          ),
          MessageWidget(message: message.message),
        ],
      ),
    );
  }
}

class GeneratedImageMessage extends StatelessWidget {
  final Message message;
  final String name;
  const GeneratedImageMessage(this.message, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NameRowWidget(
            name: name,
            icon: SvgPicture.asset("images/network.svg",
              colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
              width: 20,
            ),
          ),
          ImageWidget(message: message.message, image: Image.memory(message.imageContent!.imageData, width: message.imageContent!.width.toDouble(), height: message.imageContent!.height.toDouble(), fit: message.imageContent!.boxFit)),
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 5),
            child: Builder(
              builder: (context) {
                if (message.speaker == Speaker.user) {
                  return Container();
                }
                return Row(
                  children: [
                      Opacity(
                        opacity: message.allowedCopy ? 1.0 : 0.25,
                        child:
                            IconButton.filled(
                              icon: SvgPicture.asset("images/copy.svg",
                                colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
                                width: 20,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: intelGrayLight,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              tooltip: message.allowedCopy ? "Copy to clipboard" : null,
                              onPressed: message.imageContent?.imageData == null || message.allowedCopy == false ? null : () {

                                final clipboard = SystemClipboard.instance;
                                if (clipboard == null) {
                                  return; // Clipboard API is not supported on this platform.
                                }
                                final item = DataWriterItem();
                                item.add(Formats.jpeg(message.imageContent!.imageData));
                                clipboard.write([item]);

                              },
                            )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: intelGrayLight,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: SvgPicture.asset("images/stats.svg",
                            colorFilter: const ColorFilter.mode(textColor, BlendMode.srcIn),
                            width: 20,
                          ),
                          tooltip: "Show stats",
                          onPressed: () {
                            showMetricsDialog(context, message.metrics!);
                          },
                        ),
                      ),
                    ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

void showMetricsDialog(BuildContext context, TTIMetrics metrics) {
  showDialog<Metrics>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: TTICirclePropRow(
          metrics: metrics
        )
      );
    }
  );
}

class NameRowWidget extends StatelessWidget {
  final String name;
  final Widget icon;
  const NameRowWidget({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: intelBlueVibrant,
            //color: intelGrayLight,
          ),
          child: icon
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(name),
        )
      ]
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String message;
  const MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 34.0, top: 10, right: 26),
      child: SelectableText(
        message,
        style: const TextStyle(
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }

}

class ImageWidget extends StatelessWidget {
  final String message;
  final Image? image;
  const ImageWidget({super.key, required this.message, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 34.0, top: 10, right: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image widget goes here
          image ?? Container(),
          const SizedBox(height: 8), // Add some spacing between image and text
          SelectableText(
            message,
            style: const TextStyle(
              color: textColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
