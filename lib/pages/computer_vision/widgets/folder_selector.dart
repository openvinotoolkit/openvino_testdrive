import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
      controller.text = result.toString();
      widget.onSubmit(result.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        Row(
          children: [
            Expanded(child: TextBox(
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
      ],
    );
  }
}
