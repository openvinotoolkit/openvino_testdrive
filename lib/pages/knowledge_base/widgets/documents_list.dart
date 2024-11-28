import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/llm_inference.dart';
import 'package:inference/interop/sentence_transformer.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/langchain/object_box_store.dart';
import 'package:inference/langchain/openvino_embeddings.dart';
import 'package:inference/langchain/openvino_llm.dart';
import 'package:inference/langchain/pdf_loader.dart';
import 'package:inference/objectbox.g.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/controls/drop_area.dart';
import 'package:langchain/langchain.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DocumentsList extends StatefulWidget {
  final KnowledgeGroup group;
  const DocumentsList({super.key, required this.group});

  @override
  State<DocumentsList> createState() => _DocumentsListState();
}

class _DocumentsListState extends State<DocumentsList> {
  late Box<KnowledgeDocument> documentBox;
  late Box<EmbeddingEntity> embeddingsBox;

  void addDocument(String path) async {
    print("importing $path");
    final document = KnowledgeDocument(path);
    document.group.target = widget.group;
    documentBox.put(document);


    final platformContext = Context(style: Style.platform);
    final directory = await getApplicationSupportDirectory();
    final embeddingsModelPath = platformContext.join(directory.path, "test", "all-MiniLM-L6-v2", "fp16");
    final transformer = await SentenceTransformer.init(embeddingsModelPath, "CPU");

    const uuid = Uuid();

    final lcDocuments = await PdfLoader(path, 400).load();
    List<EmbeddingEntity> entities = [];
    for (final lcDocument in lcDocuments) {
      final embeddings = await transformer.generate(lcDocument.pageContent);
      final entity = EmbeddingEntity(uuid.v4(), lcDocument.pageContent, jsonEncode(lcDocument.metadata), embeddings);
      entity.document.target = document;
      entities.add(entity);
    }
    embeddingsBox.putMany(entities);

    print("Added ${entities.length} embeddings for $path");
  }

  @override
  void initState() {
    super.initState();
    documentBox = ObjectBox.instance.store.box<KnowledgeDocument>();
    embeddingsBox = ObjectBox.instance.store.box<EmbeddingEntity>();
  }
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridContainer(
          color: backgroundColor.of(theme),
          padding: const EdgeInsets.all(16),
          child: Text(widget.group.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Button(
                    onPressed: () {

                    },
                    child: const Text("add document"),
                  ),
                  DropArea(
                    type: "a document",
                    showChild: widget.group.documents.isNotEmpty,
                    onUpload: (file) => addDocument(file),
                    child: Column(
                      children: [
                        for (final document in widget.group.documents)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(document.source),
                              Text("embeddings: ${document.sections.length}")
                            ],
                          )
                      ],
                    )
                  ),
                  Experiment(group: widget.group),
                ],
              );
            }
          ),
        ),
      ],
    );
  }
}

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
