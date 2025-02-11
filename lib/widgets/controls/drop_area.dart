// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';

class DropArea extends StatefulWidget {
  final Widget? child;
  final bool showChild;
  final void Function(List<String>) onUpload;
  final String type;
  final List<String>? extensions;

  const DropArea({
      super.key,
      required this.child,
      required this.showChild,
      required this.onUpload,
      required this.type,
      this.extensions
  });

  @override
  State<DropArea> createState() => _DropAreaState();
}

class _DropAreaState extends State<DropArea> {
  bool _showReleaseMessage = false;

  void handleDrop(DropDoneDetails details) {
    widget.onUpload(
      details.files
        .where((file) {
          String extension = file.path.split('.').last.toLowerCase(); // Extract file extension
          return widget.extensions?.contains(extension) ?? true;
        })
        .map((f) => f.path)
        .toList()
    );
  }

  void showUploadMenu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final files = result.files.map((m) => m.path).whereType<String>().toList();
      if (files.isNotEmpty) {
        widget.onUpload(files);
      }
    }
  }

  void showReleaseMessage() {
    setState(() => _showReleaseMessage = true);
  }

  void hideReleaseMessage() {
    setState(() => _showReleaseMessage = false);
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: handleDrop,
      onDragExited: (_) => hideReleaseMessage(),
      onDragEntered: (_) => showReleaseMessage(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Builder(
          builder: (context) {
            if (widget.showChild && !_showReleaseMessage) {
              // If we have a child and aren't showing the drop message, display it.
              return widget.child ?? const SizedBox.shrink();
            }

            final theme = FluentTheme.of(context);
            final String text = _showReleaseMessage
                ? "Release to drop"
                : "Drag and drop ${widget.type}";

            return Center(
              child: SizedBox(
                height: 310,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Top text
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // SVG scales to available space in the column
                    Expanded(
                      // FittedBox automatically scales its child to fit the parent's constraints
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: theme.brightness.isDark
                            ? SvgPicture.asset('images/drop.svg')
                            : SvgPicture.asset('images/drop_light.svg'),
                      ),
                    ),

                    // Optional file extension text at the bottom
                    if (widget.extensions != null)
                      Text(widget.extensions!.join(", "))
                    else
                      const SizedBox.shrink(),
                  ],
                )
              ),
            );
          },
        ),
      )
    );
  }
}
