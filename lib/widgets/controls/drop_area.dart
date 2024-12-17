// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';

class DropArea extends StatefulWidget {
  final Widget? child;
  final bool showChild;
  final void Function(String) onUpload;
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
    if (details.files.isNotEmpty) {
      widget.onUpload(details.files[0].path);
    }
  }

  void showUploadMenu() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      widget.onUpload(result.files.single.path!);
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
    final theme = FluentTheme.of(context);

    return DropTarget(
      onDragDone: (details) => handleDrop(details),
      onDragExited: (val) => hideReleaseMessage(),
      onDragEntered: (val) => showReleaseMessage(),

      child: Builder(
        builder: (context) {
          if (widget.showChild && !_showReleaseMessage) {
            return widget.child ?? Container();
          }

          final String text = _showReleaseMessage
            ? "Release to drop media"
            : "Drag and drop ${widget.type} here for testing";


          return Center(
            child: SizedBox(
              height: 310,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(text, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
                  (theme.brightness.isDark
                    ? SvgPicture.asset('images/drop.svg')
                    : SvgPicture.asset('images/drop_light.svg')
                  ),
                  Builder(
                    builder: (context) {
                      if (widget.extensions == null) {
                        return Container();
                      }
                      return Text(widget.extensions!.join(", "));
                    }
                  )
                ],
              ),
            ),
          );
        }
      )
    );

  }
}
