import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';

Future<String?> changeNameDialog(BuildContext context, KnowledgeGroup group) async {

  return showDialog<String?>(
    context: context,
    builder: (context) => ChangeNameDialog(group: group),
  );
}

class ChangeNameDialog extends StatefulWidget {
  final KnowledgeGroup group;
  const ChangeNameDialog({required this.group, super.key});

  @override
  State<ChangeNameDialog> createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<ChangeNameDialog> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    _controller.text = widget.group.name;
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 300,
      ),
      title: const Text("Rename"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text("Name"),
          ),
          TextBox(
            controller: _controller,
            focusNode: _focusNode,
          )
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Update'),
        ),
        Button(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
      ]
    );
  }
}
