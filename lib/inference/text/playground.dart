
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/config.dart';
import 'package:inference/hint.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/inference/text/metric_widgets.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:inference/utils/dialogs.dart';
import 'package:provider/provider.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
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
    final llm = provider();
    if (!llm.initialized) {
      return;
    }

    if (llm.response != null) {
      return;
    }
    _controller.text = "";
    jumpToBottom(offset: 110); //move to bottom including both
    llm.message(message).catchError(onExceptionDialog(context));

  }

  TextInferenceProvider provider() => Provider.of<TextInferenceProvider>(context, listen: false);

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
    return Consumer<TextInferenceProvider>(builder: (context, inference, child) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (attachedToBottom) {
            jumpToBottom();
          }
        });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
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
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                                          case Speaker.system:
                                            throw UnimplementedError();
                                          case Speaker.user:
                                            return UserMessage(message);
                                          case Speaker.assistant:
                                            return AssistantMessage(message, inference.project!.name);
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

                      SizedBox(
                        height: 30,
                        child: Builder(
                          builder: (context) {
                            if (inference.interimResponse == null){
                              return Container();
                            }
                            return Center(
                              child: OutlinedButton.icon(
                                onPressed: () => inference.forceStop(),
                                icon: const Icon(Icons.stop),
                                label: const Text("Stop responding")
                              ),
                            );
                          }
                        ),
                      ),
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

class UserMessage extends StatelessWidget {
  final Message message;
  const UserMessage(this.message, {super.key});

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

class AssistantMessage extends StatelessWidget {
  final Message message;
  final String name;
  const AssistantMessage(this.message, this.name, {super.key});

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
          MessageWidget(message: message.message),
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 5),
            child: Builder(
              builder: (context) {
                if (message.metrics == null) {
                  return Container();
                }
                return Row(
                  children: [
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
                      tooltip: "Copy to clipboard",
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: message.message));
                      },
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

void showMetricsDialog(BuildContext context, Metrics metrics) {
  showDialog<Metrics>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: CirclePropRow(
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
