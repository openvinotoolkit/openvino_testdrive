import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';
import 'package:inference/pages/knowledge_base/widgets/group_item.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';

class Tree extends StatefulWidget {
  const Tree({
      super.key
  });

  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  late Box<KnowledgeGroup> groupBox;
  List<KnowledgeGroup> groups = [];
  KnowledgeGroup? activeGroup;
  int? editId;

  @override
  void initState() {
    super.initState();
    groupBox = ObjectBox.instance.store.box<KnowledgeGroup>();
    groupBox.getAllAsync().then((b) {
        setState(() {
            groups = b;
            activeGroup = b.first;
        });
    });

  }
  void renameGroup(KnowledgeGroup group, String value) {
    setState(() {
      editId = null;
      groupBox.put(group..name = value);
    });
  }

  void deleteGroup(KnowledgeGroup group) {
    groupBox.remove(group.internalId);
    setState(() {
        groups.remove(group);
    });
  }

  void addGroup() {
    setState(() {
      editId = groupBox.put(KnowledgeGroup("New group"));
      groups = groupBox.getAll();
    });
  }

  void setActiveGroup(KnowledgeGroup group) {
    activeGroup = group;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return GridContainer(
      color: backgroundColor.of(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TreeView(
            selectionMode: TreeViewSelectionMode.single,
            onSelectionChanged: (selection) async {
              print((selection.first.value as KnowledgeGroup).name);
              setState(() {
                activeGroup = selection.first.value;
              });
            },
            items: [
              for (final group in groups)
                TreeViewItem(
                  value: group,
                  selected: activeGroup == group,
                  content: GroupItem(
                    editable: editId == group.internalId,
                    group: group,
                    onRename: (value) => renameGroup(group, value),
                    onMakeEditable: () {
                      setState(() {
                          editId = group.internalId;
                      });
                    },
                    onDelete: () => deleteGroup(group),
                  )
                ),
            ]
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Button(
              onPressed: addGroup,
              child: const Text("Add group"),
            ),
          ),
        ],
      ),
    );
  }
}
