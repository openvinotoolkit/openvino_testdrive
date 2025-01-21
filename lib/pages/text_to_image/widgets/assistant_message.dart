import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/text_to_image_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:super_clipboard/super_clipboard.dart';

class GeneratedImageMessage extends StatefulWidget {
  final ImageMessage message;
  final ImageProvider icon;
  final String name;

  const GeneratedImageMessage(this.message, this.icon, this.name, {super.key});

  @override
  State<GeneratedImageMessage> createState() => _GeneratedImageMessageState();
}

class _GeneratedImageMessageState extends State<GeneratedImageMessage> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
        locale: locale.languageCode, decimalDigits: 0);
    final theme = FluentTheme.of(context);
    final backgroundColor = theme.brightness.isDark
        ? theme.scaffoldBackgroundColor
        : const Color(0xFFF5F5F5);

    final image = SmartImageWidget(message: widget.message);

    void showContentDialog(BuildContext context) async {
      if (image.hasClipboard()) {
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

    return Consumer<TextToImageInferenceProvider>(
      builder: (context, inferenceProvider, child) => Align(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: inferenceProvider.project!.thumbnailImage(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SelectionContainer.disabled(
                      child: Row(
                        children: [
                          Text(
                            inferenceProvider.project!.name,
                            style: TextStyle(
                              color: subtleTextColor.of(theme),
                            ),
                          ),
                          if (widget.message.time != null)
                            Text(
                              DateFormat(' | yyyy-MM-dd HH:mm:ss')
                                  .format(widget.message.time!),
                              style: TextStyle(
                                color: subtleTextColor.of(theme),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() {
                      _hovering = true;
                    }),
                    onExit: (_) => setState(() {
                      _hovering = false;
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width - 502),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(children: [
                              Column(children: [
                                      // Changes cursor to hand on hover when there's a dialog that can be opened
                                      MouseRegion(
                                          cursor: image.hasClipboard()
                                              ? SystemMouseCursors.click
                                              : SystemMouseCursors.basic,
                                          child: GestureDetector(
                                              onTap: () =>
                                                  showContentDialog(context),
                                              // Opens dialog on click
                                              child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxHeight: 256.0,
                                                    maxWidth: 256.0,
                                                  ),
                                                  child: image))),
                                    ])
                                  ,
                            ]),
                          ),
                        ),
                        if (_hovering && image.hasClipboard())
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SelectionContainer.disabled(
                              child: Row(
                                children: [
                                  if (widget.message.metrics != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Tooltip(
                                        message: 'Generation time',
                                        child: Text(
                                          '${nf.format(widget.message.metrics!.generate_time)}ms',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: subtleTextColor.of(theme),
                                          ),
                                        ),
                                      ),
                                    ),
                                  IconButton(
                                    icon: const Icon(FluentIcons.copy),
                                    onPressed: () async {
                                      await displayInfoBar(
                                        context,
                                        builder: (context, close) => InfoBar(
                                          title:
                                              const Text('Copied to clipboard'),
                                          severity: InfoBarSeverity.info,
                                          action: IconButton(
                                            icon: const Icon(FluentIcons.clear),
                                            onPressed: close,
                                          ),
                                        ),
                                      );
                                      image.copyToClipboard();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 34)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmartImageWidget extends StatelessWidget {
  final ImageMessage message;

  const SmartImageWidget({super.key, required this.message});

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

