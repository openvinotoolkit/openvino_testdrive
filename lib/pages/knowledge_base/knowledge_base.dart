import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/langchain/openvino_embeddings.dart';
import 'package:inference/objectbox.g.dart';
import 'package:inference/pages/knowledge_base/providers/knowledge_base_provider.dart';
import 'package:inference/pages/knowledge_base/widgets/tree.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

class KnowledgeBase extends StatefulWidget {
  const KnowledgeBase({super.key});

  @override
  State<KnowledgeBase> createState() => _KnowledgeBaseState();
}

class _KnowledgeBaseState extends State<KnowledgeBase> {
  final controller = TextEditingController();
  late Box<EmbeddingEntity> embeddingsBox;
  late Box<KnowledgeGroup> groupBox;
  OpenVINOEmbeddings? embeddingsModel;

  List<KnowledgeGroup> groups = [];
  KnowledgeGroup? activeGroup;

  void initEmbeddings() async {
    final platformContext = Context(style: Style.platform);
    final directory = await getApplicationSupportDirectory();
    final device = "CPU";
    final embeddingsModelPath = platformContext.join(directory.path, "test", "all-MiniLM-L6-v2", "fp16");
    embeddingsModel = await OpenVINOEmbeddings.init(embeddingsModelPath, device);

  }
  @override
  void initState() {
    super.initState();

    embeddingsBox = ObjectBox.instance.store.box<EmbeddingEntity>();
    groupBox = ObjectBox.instance.store.box<KnowledgeGroup>();
  }

  void test() async {
    print("all embeddings: ");
    for (final embedding in embeddingsBox.getAll()) {
      print(embedding.content);
    }
    final promptEmbeddings = await embeddingsModel!.embedQuery(controller.text);
    final query = embeddingsBox
      .query(EmbeddingEntity_.embeddings.nearestNeighborsF32(promptEmbeddings, 2))
      .build();

    final results = query.findWithScores();
    for (final result in results) {
      print("Embedding ID: ${result.object.id}, distance: ${result.score}, text: ${result.object.document.target!.source}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onTap: () {
        final data = Provider.of<KnowledgeBaseProvider>(context, listen: false);
        print("on tap outside");
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
        ],
      ),
    );
  }
}
