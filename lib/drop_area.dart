import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:inference/zoomable_image.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:inference/theme.dart';

class DropArea extends StatefulWidget {
  final Widget? child;
  final bool showChild;
  final void Function(String) onUpload;
  const DropArea({required this.child, required this.showChild, required this.onUpload, super.key});

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
    return Expanded(
      child: DropTarget(
        onDragDone: (details) => handleDrop(details),
        onDragExited: (val) => hideReleaseMessage(),
        onDragEntered: (val) => showReleaseMessage(),
        child: Container(
          color: intelGray,
          child: Builder(
            builder: (context) {
              if (!_showReleaseMessage && widget.showChild) {
                return widget.child!;
              }
              return Center(
                child: SizedBox(
                  height: 310,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset('images/drop.svg'),
                      ( _showReleaseMessage
                        ? const Text("Release to drop media")
                        : const Text("Drop image here for testing")
                      ),
                      ElevatedButton(
                        onPressed: () => showUploadMenu(),
                        child: const Text("Upload")
                      ),
                      const Text("jpg, jpeg, bmp, png, tif, tiff")
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
