// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/all_mini_lm_v6.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/pages/knowledge_base/providers/knowledge_base_provider.dart';
import 'package:inference/pages/knowledge_base/widgets/documents_list.dart';
import 'package:inference/pages/knowledge_base/widgets/tree.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/download_request_widget.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:provider/provider.dart';


class KnowledgeBasePage extends StatefulWidget {
  const KnowledgeBasePage({super.key});

  @override
  State<KnowledgeBasePage> createState() => _KnowledgeBasePageState();
}

class _KnowledgeBasePageState extends State<KnowledgeBasePage> {

  Future<void>? allMiniLMV6;

  @override
  void initState() {
    super.initState();

    final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    allMiniLMV6 = AllMiniLMV6.ensureModelIsPresent(downloadProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: allMiniLMV6,
      builder: (context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (_) => KnowledgeBaseProvider(
              groupBox: ObjectBox.instance.store.box<KnowledgeGroup>()
            ),
            child: const KnowledgeBase()
          );
        }

        return DownloadRequestWidget(id: AllMiniLMV6.id);
      }
    );
  }
}

class KnowledgeBase extends StatelessWidget {
  const KnowledgeBase({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GridContainer(
                color: backgroundColor.of(theme),
                padding: const EdgeInsets.all(16),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                ),
                child: const Text("Knowledge Base",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Expanded(
                child: Tree(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<KnowledgeBaseProvider>(
            builder: (context, data, child) {
              if (data.activeGroup != null) {
                final group = data.groupBox.get(data.activeGroup!);
                if (group != null) {
                  return DocumentsList(group: group, key: Key(group.internalId.toString()));
                }
              }
              return const Center(child: Text("Select a group from the list to the left"));
            }
          ),
        ),
      ],
    );
  }
}
