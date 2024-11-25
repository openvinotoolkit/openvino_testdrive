import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/interop/sentence_transformer.dart';
import 'package:inference/langchain/openvino_embeddings.dart';
import 'package:inference/langchain/openvino_llm.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class KnowledgeBase extends StatefulWidget {
  const KnowledgeBase({super.key});

  @override
  State<KnowledgeBase> createState() => _KnowledgeBaseState();
}

class _KnowledgeBaseState extends State<KnowledgeBase> {
  final controller = TextEditingController();
  MemoryVectorStore? vs;
  OpenVINOLLM? model;
  Runnable? chain;
  Future<String>? response;

  void initMemoryStore() async {
    final platformContext = Context(style: Style.platform);
    final directory = await getApplicationSupportDirectory();
    final device = "CPU";
    final embeddingsModelPath = platformContext.join(directory.path, "test", "all-MiniLM-L6-v2", "fp16");
    final llmModelPath = platformContext.join(directory.path, "test", "TinyLlama-1.1B-Chat-v1.0-int8-ov");
    final embeddings = await OpenVINOEmbeddings.init(embeddingsModelPath, device);
    vs = MemoryVectorStore(embeddings:  embeddings);
    vs!.addDocuments(documents: const [
        Document(pageContent: 'Payment methods: iDEAL, PayPal and credit card'),
        Document(pageContent: 'Free shipping: on orders over 30€'),
    ]);

    model = OpenVINOLLM(await LLMInference.init(llmModelPath, device),
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

    chain = Runnable.fromMap<String>({
      'context': retriever | Runnable.mapInput((docs) => docs.map((d) => d.pageContent).join('\n')),
      'question': Runnable.passthrough(),
    }) | promptTemplate | model! | const StringOutputParser();
    print(chain);

  }

  @override
  void initState() {
    super.initState();
    initMemoryStore();
  }

  //final modelPath = "/Users/rhecker/data/genai/all-MiniLM-L6-v2/fp16";
  void test() async {
    //model!.inference.clearHistory();
    final output = chain!.invoke(controller.text);
    setState(() {
      response = output.then((p) => p.toString());
    });
    //await chain!.stream(controller.text).forEach((p) => print(p));
    //print(await vs!.similaritySearch(query: controller.text));

    //final transformer = await SentenceTransformer.init(modelPath, "CPU");
    //print(await transformer.generate(controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextBox(
          controller: controller,
        ),
        Button(
            onPressed: () => test(),
            child: const Text("test"),
        ),
        FutureBuilder<String>(
          future: response,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("loading");
            }
            if (snapshot.hasData) {
              return Text(snapshot.data!);
            }
            return const Text("...");
          },
        )
      ],
    );
  }
}
