import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/widgets/horizontal_rule.dart';
import 'package:inference/pages/knowledge_base/utils/loader_selector.dart';
import 'package:path/path.dart';

Future<List<String>> importDialog(BuildContext context, List<String> files) async {
  final result = await showDialog<List<String>?>(
    context: context,
    builder: (context) => ImportRAGWidget(
      paths: files,
    ),
  );
  if (result != null) {
    return result;
    //return result.map((key, value) => MapEntry(key, loaderFromName(value, key)));
  } else {
    return List<String>.of([]);
  }
}

class ImportRAGWidget extends StatefulWidget {
  final List<String> paths;

  const ImportRAGWidget({
    super.key,
    required this.paths,
  });

  @override
  State<ImportRAGWidget> createState() => _ImportRAGWidgetState();
}

class _ImportRAGWidgetState extends State<ImportRAGWidget> {
  late final String baseDir;
  late final Map<String, bool> _files;

  @override
  void initState() {
    super.initState();

    baseDir = dirname(widget.paths.first);
    _files = { for (var p in buildFilesListFromPaths(widget.paths)) p : true };
  }

  List<String> buildFilesListFromPaths(List<String> paths) {
    return paths.map((path) {
        final dir = Directory(path);
        if (dir.existsSync()) {
          // its a directory
          final content = dir.listSync(recursive: true).map((p) => p.path);
          return content.toList();
        } else {
          // its a file
          return [path];
        }
      })
      .expand((b) => b) //expand flattens list
      .where((file) => loaderFromPath(file) != null)
      .toList();
  }


  List<String>  get files => _files.keys.toList();
  List<String>  get selectedFiles => _files.keys.where((file) => _files[file] ?? false).toList();

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
              child: TreeView(
                onItemInvoked: (item, reason) async {
                  print('onItemInvoked: $item => ${item.selected}');
                  if (_files.containsKey(item.value)) {
                    setState(() {
                      _files[item.value] = !_files[item.value]!;
                    });
                  }
                },
                selectionMode: TreeViewSelectionMode.multiple,
                items: [
                  for (final file in files)
                    TreeViewItem(
                      selected: _files[file],
                      content: Text(file.substring(baseDir.length + 1)),
                      value: file,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: selectedFiles.isNotEmpty
            ? () {
              Navigator.pop(context, selectedFiles);
              // Delete file here
            }
            : null,
          child: const Text('Import'),
        ),
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, null),
        ),
      ],
    );
  }
}
