// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/widgets/controls/no_outline_button.dart';
import 'package:provider/provider.dart';

class  KnowledgeBaseSelector extends StatefulWidget {
  const KnowledgeBaseSelector({super.key});

  @override
  State<KnowledgeBaseSelector> createState() => _KnowledgeBaseSelectorState();
}

class _KnowledgeBaseSelectorState extends State<KnowledgeBaseSelector> {
  late List<KnowledgeGroup> groups;

  @override
  void initState() {
    super.initState();
    groups = ObjectBox.instance.store.box<KnowledgeGroup>().getAll();
  }

  @override
  Widget build(BuildContext context) {
      return Consumer<TextInferenceProvider>(builder: (context, inference, child) {
        return DropDownButton(
          buttonBuilder: (context, callback) {
            return NoOutlineButton(
              onPressed: callback,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    (inference.knowledgeGroup == null
                      ? const Text("Knowledge Base")
                      : Text("Knowledge Base: ${inference.knowledgeGroup!.name}")
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(FluentIcons.chevron_down, size: 12),
                    ),
                  ],
                ),
              ),
            );
          },
          items: [
            MenuFlyoutItem(text: const Text("None"), onPressed: () {
                inference.knowledgeGroup = null;
            }),
            for (final group in groups)

              MenuFlyoutItem(text: Text(group.name), onPressed: () {
                inference.knowledgeGroup = group;
              })
          ]
        );
      }
    );
    }
}
