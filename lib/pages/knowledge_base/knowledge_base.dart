import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/langchain/openvino_embeddings.dart';
import 'package:inference/objectbox.g.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class KnowledgeBase extends StatefulWidget {
  const KnowledgeBase({super.key});

  @override
  State<KnowledgeBase> createState() => _KnowledgeBaseState();
}

class _KnowledgeBaseState extends State<KnowledgeBase> {
  final controller = TextEditingController();
  late Box<EmbeddingEntity> embeddingsBox;
  OpenVINOEmbeddings? embeddingsModel;


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

    //final output = chain!.invoke(controller.text);
    //setState(() {
    //  response = output.then((p) => p.toString());
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
