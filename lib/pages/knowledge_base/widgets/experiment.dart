import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box_store.dart';
import 'package:inference/langchain/openvino_embeddings.dart';
import 'package:inference/langchain/openvino_llm.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Experiment extends StatefulWidget {
  final KnowledgeGroup group;
  const Experiment({super.key, required this.group});

  @override
  State<Experiment> createState() => _ExperimentState();
}

class _ExperimentState extends State<Experiment> {
  VectorStore? vs;
  Future<Runnable>? chain;
  String? response;

  Future<Runnable> initMemoryStore() async {
    final platformContext = Context(style: Style.platform);
    final directory = await getApplicationSupportDirectory();
    const device = "CPU";
    final embeddingsModelPath = platformContext.join(directory.path, "test", "all-MiniLM-L6-v2", "fp16");
    final llmModelPath = platformContext.join(directory.path, "test", "TinyLlama-1.1B-Chat-v1.0-int8-ov");
    final embeddingsModel = await OpenVINOEmbeddings.init(embeddingsModelPath, device);
    vs = ObjectBoxStore(embeddings:  embeddingsModel, group: widget.group);
    final model = OpenVINOLLM(await LLMInference.init(llmModelPath, device),
      defaultOptions: const OpenVINOLLMOptions(temperature: 1, topP: 1, applyTemplate: false)
    );
    final promptTemplate = ChatPromptTemplate.fromTemplate('''
<|system|>
Answer the question based only on the following context without specifically naming that it's from that context:
{context}

<|user|>
{question}
<|assistant|>
''');
    final retriever = vs!.asRetriever();

    return Runnable.fromMap<String>({
      'context': retriever | Runnable.mapInput((docs) => docs.map((d) => d.pageContent).join('\n')),
      'question': Runnable.passthrough(),
    }) | promptTemplate | model | const StringOutputParser();
  }


  void runChain(String text) async {
    final runnable = (await chain)!;
    setState(() {
        response = "";
    });
    await for (final output in runnable.stream(text)) {
      setState(() {
          response = (response ?? "") + output.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    chain = initMemoryStore();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Runnable>(
      future: chain,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Image.asset('images/intel-loading.gif', width: 100)
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("Experiment area"),
              ),
              TextBox(
                onSubmitted: runChain,
              ),
              Builder(
                builder: (context) {
                  if (response != null) {
                    return SingleChildScrollView(child: SelectableText(response!.isEmpty ? "..." : response!));
                  }
                  return const Text("Type a message to test RAG");
                }
              )
            ],
          ),
        );
      }
    );
  }
}
