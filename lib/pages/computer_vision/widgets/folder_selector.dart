// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart';

class FolderSelector extends StatefulWidget {
  final String label;
  final void Function(String) onSubmit;
  const FolderSelector({
      super.key,
      required this.onSubmit,
      required this.label,
  });

  @override
  State<FolderSelector> createState() => _FolderSelectorState();
}

class _FolderSelectorState extends State<FolderSelector> {
  final controller = TextEditingController();

  void showUploadMenu() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setPath(result.toString());
    }
  }

  void setPath(String path) {
    controller.text = path;
    widget.onSubmit(path);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool disable = Platform.isMacOS;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DropTarget(
          onDragDone: (details) {
            final platformContext = Context(style: Style.platform);
            if (Directory(details.files.first.path).existsSync()) {
              // folder is dragged in
              setPath(details.files.first.path);
            } else {
              // file was dragged in, taking file dir.
              final directory = platformContext.dirname(details.files.first.path);
              setPath(directory);
            }
          },
          child: Row(
            children: [
              Expanded(child: TextBox(
                  enabled: !disable,
                  controller: controller,
                  placeholder: "Drop ${widget.label.toLowerCase()} in",
                  onChanged: widget.onSubmit,
              )),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Button(
                  onPressed: showUploadMenu,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(FluentIcons.fabric_folder),
                        ),
                        const Text("Select"),
                      ]
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
