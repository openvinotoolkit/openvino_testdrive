import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/pages/knowledge_base/providers/knowledge_base_provider.dart';
import 'package:inference/pages/knowledge_base/widgets/documents_list.dart';
import 'package:inference/pages/knowledge_base/widgets/tree.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';

class KnowledgeBasePage extends StatelessWidget {
  const KnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KnowledgeBaseProvider(
        groupBox: ObjectBox.instance.store.box<KnowledgeGroup>()
      ),
      child: const KnowledgeBase()
    );
  }

}

class KnowledgeBase extends StatelessWidget {
  const KnowledgeBase({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onTap: () {
        final data = Provider.of<KnowledgeBaseProvider>(context, listen: false);
        if (data.isEditingId != null) {
          data.isEditingId = null;
        }
      },
      behavior: HitTestBehavior.deferToChild,
      child: Row(
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
          const Expanded(
            child: DocumentsList(),
          ),
        ],
      ),
    );
  }
}
