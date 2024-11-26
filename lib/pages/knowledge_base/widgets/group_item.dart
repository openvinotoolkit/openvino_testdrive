import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';

class GroupItem extends StatefulWidget {
  final KnowledgeGroup group;
  final bool editable;
  final Function(String)? onRename;
  final Function()? onDelete;
  final Function()? onMakeEditable;
  const GroupItem({
      super.key,
      required this.group,
      required this.editable,
      this.onRename,
      this.onDelete,
      this.onMakeEditable,
  });

  @override
  State<GroupItem> createState() => _GroupItemState();
}

class _GroupItemState extends State<GroupItem> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.group.name;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editable) {
      return TextBox(
        controller: controller,
        onSubmitted: (value) {
          widget.onRename?.call(value);
        },
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: () {
        widget.onMakeEditable?.call();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.group.name),
          IconButton(icon: const Icon(FluentIcons.delete_rows), onPressed: () {
              widget.onDelete?.call();
          }),
        ],
      ),
    );
  }
}
