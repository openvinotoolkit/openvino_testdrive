import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';

class GroupItem extends StatefulWidget {
  final KnowledgeGroup group;
  final bool isActive;
  final bool editable;
  final Function(String)? onRename;
  final Function()? onActivate;
  final Function()? onDelete;
  final Function()? onMakeEditable;

  const GroupItem({
      super.key,
      required this.group,
      required this.editable,
      this.onActivate,
      this.isActive = false,
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
    final theme = FluentTheme.of(context);

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
      onTap: () {
        widget.onActivate?.call();
      },
      onDoubleTap: () {
        widget.onMakeEditable?.call();
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: widget.isActive ? theme.accentColor : Colors.transparent,
              width: 5,
            ),
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.group.name),
            IconButton(icon: const Icon(FluentIcons.delete), onPressed: () {
                widget.onDelete?.call();
            }),
          ],
        ),
      ),
    );
  }
}
