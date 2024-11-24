import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/sentence_transformer.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class KnowledgeBase extends StatefulWidget {
  const KnowledgeBase({super.key});

  @override
  State<KnowledgeBase> createState() => _KnowledgeBaseState();
}

class _KnowledgeBaseState extends State<KnowledgeBase> {
  final controller = TextEditingController();

  //final modelPath = "/Users/rhecker/data/genai/all-MiniLM-L6-v2/fp16";
  void test() async {
    final platformContext = Context(style: Style.platform);
    final directory = await getApplicationSupportDirectory();
    final modelPath = platformContext.join(directory.path, "test", "all-MiniLM-L6-v2", "fp16");

    print(modelPath);

    final transformer = await SentenceTransformer.init(modelPath, "CPU");
    print(await transformer.generate(controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      children: [
        TextBox(
          controller: controller,
        ),
        Button(
            onPressed: () => test(),
            child: const Text("test"),
        ),
      ],
    ));
  }
}
