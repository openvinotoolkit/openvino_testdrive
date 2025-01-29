// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';
import 'package:inference/pages/knowledge_base/providers/knowledge_base_provider.dart';
import 'package:inference/pages/knowledge_base/widgets/group_item.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';

class Tree extends StatefulWidget {
  const Tree({
      super.key
  });

  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  late Box<KnowledgeGroup> groupBox;
  late Stream<Query<KnowledgeGroup>> groupStream;


  @override
  void initState() {
    super.initState();
    groupBox = ObjectBox.instance.store.box<KnowledgeGroup>();
    groupStream = groupBox.query().watch(triggerImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return StreamBuilder<Query<KnowledgeGroup>>(
      stream: groupStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        final groups = snapshot.data?.find() ?? [];
        return Consumer<KnowledgeBaseProvider>(
          builder: (context, data, child) {
            return GridContainer(
              color: backgroundColor.of(theme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 18, bottom: 18),
                    child: Button(
                      onPressed: data.addGroup,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Icon(FluentIcons.fabric_new_folder, size: 18),
                          ),
                          Text("Create new"),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      for (final group in groups)
                        GroupItem(
                          isActive: data.activeGroup == group.internalId,
                          group: group,
                          onActivate: () {
                            data.setActiveGroup(group);
                          },
                          onDelete: () async {
                            if (await confirmDeleteDialog(context)) {
                              data.deleteGroup(group);
                            }
                          }
                        ),
                    ]
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
}

 Future<bool> confirmDeleteDialog(BuildContext context) async {
  final result = await showDialog<bool?>(
    context: context,
    builder: (context) => ContentDialog(

      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      title: const Text('Delete knowledge base?'),
      content: const Text(
        "Are you sure you want to remove the knowledge base?",
      ),
      actions: [
        Button(
          child: const Text('Delete'),
          onPressed: () {
            Navigator.pop(context, true);
            // Delete file here
          },
        ),
        FilledButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    ),
  );
  return result == true;
}
