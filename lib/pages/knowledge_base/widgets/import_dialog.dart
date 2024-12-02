import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/widgets/horizontal_rule.dart';
import 'package:inference/pages/knowledge_base/utils/loader_selector.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';

Future<Map<String, BaseDocumentLoader>> importDialog(BuildContext context, String path) async {
  final result = await showDialog<Map<String, String>?>(
    context: context,
    builder: (context) => ImportRAGWidget(
      path: path,
    ),
  );
  if (result != null) {
    return result.map((key, value) => MapEntry(key, loaderFromName(value, key)));
  } else {
    return Map<String, BaseDocumentLoader>.of({});
  }
}

class ImportRAGWidget extends StatefulWidget {
  final String path;

  const ImportRAGWidget({
    super.key,
    required this.path,
  });

  @override
  State<ImportRAGWidget> createState() => _ImportRAGWidgetState();
}

class _ImportRAGWidgetState extends State<ImportRAGWidget> {
  late final String baseDir;
  late final Map<String, String> files;

  @override
  void initState() {
    super.initState();
    final dir = Directory(widget.path);
    if (dir.existsSync()) {
      // its a directory
      final content = dir.listSync(recursive: true).map((p) => p.path);
      baseDir = widget.path;
      files = Map.fromIterable(content, key: (path) {
          return path;
        },
        value: (path) {
          return defaultLoaderSelector(path);
        }
      );
    } else {
      // its a file
      final loader = defaultLoaderSelector(widget.path);
      baseDir = dirname(widget.path);
      files = {widget.path: loader};
    }

  }
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 756,
        maxHeight: 500,
      ),
      title: const Text('Import files?'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("From directory: $baseDir"),
          const HorizontalRule(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children:  [
                  for (final key in files.keys)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(key.substring(baseDir.length)),
                          Row(
                            children: [
                              LoaderSelector(
                                value: files[key]!,
                                onChange: (value) {
                                  setState(() {
                                    files[key] = value;
                                  });
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                     files.remove(key);
                                  });
                                },
                                icon: const Icon(FluentIcons.delete),
                              )
                            ],
                          ),
                        ]
                      ),
                    ),
                ]
              ),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          child: const Text('Import'),
          onPressed: () {
            Navigator.pop(context, files);
            // Delete file here
          },
        ),
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
      ],
    );
  }
}

const List<String> loaders = ["PdfLoader", "TextLoader", "HTMLLoader"];

class LoaderSelector extends StatelessWidget {
  final String value;
  final Function(String) onChange;
  const LoaderSelector({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return ComboBox(
      value: value,
      items: [
        for (final loader in loaders)
          ComboBoxItem<String>(
            value: loader,
            child: Text(loader),
          ),
      ],
      onChanged: (v) => onChange(v!)
    );
  }
}
