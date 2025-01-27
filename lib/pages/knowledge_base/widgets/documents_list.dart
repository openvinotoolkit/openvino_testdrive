// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/sentence_transformer.dart';
import 'package:inference/langchain/all_mini_lm_v6.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';
import 'package:inference/pages/knowledge_base/providers/knowledge_base_provider.dart';
import 'package:inference/pages/knowledge_base/utils/loader_selector.dart';
import 'package:inference/pages/knowledge_base/widgets/change_name_dialog.dart';
import 'package:inference/pages/knowledge_base/widgets/import_dialog.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/controls/drop_area.dart';
import 'package:langchain/langchain.dart';
import 'package:provider/provider.dart';
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
  Future<SentenceTransformer>? transformerFuture;

  late List<KnowledgeDocument> documents;
  Map<String, BaseDocumentLoader>? filesToImport;

  Future<KnowledgeDocument> addDocument(String path, BaseDocumentLoader loader) async {
    print("importing $path");
    final document = KnowledgeDocument(path);
    document.group.target = widget.group;
    documentBox.put(document);

    const uuid = Uuid();
    final transformer = await transformerFuture;

    if (transformer == null){
      throw Exception("Could not loading transformer");
    }

    final lcDocuments = await loader.load();
    List<EmbeddingEntity> entities = [];
    for (final lcDocument in lcDocuments) {
      final embeddings = await transformer.generate(lcDocument.pageContent);
      final entity = EmbeddingEntity(uuid.v4(), lcDocument.pageContent, jsonEncode(lcDocument.metadata), embeddings);
      entity.document.target = document;
      entities.add(entity);
    }
    embeddingsBox.putMany(entities);

    print("Added ${entities.length} embeddings for $path");
    return document;
  }


  Future<SentenceTransformer> initSentenceTransformer() async {
    //bit hacky, perhaps move to init of provider?
    final embeddingsModelPath = await AllMiniLMV6.storagePath;
    return SentenceTransformer.init(embeddingsModelPath, "CPU");
  }

  void processUpload(BuildContext context, List<String> paths) async {
    final files = await importDialog(context, paths);
    for (final file in files){
      final loader = loaderFromPath(file);
      if (loader != null) {
        final newDocument = await addDocument(file, loader);
        setState(() {
          documents.add(newDocument);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    documentBox = ObjectBox.instance.store.box<KnowledgeDocument>();
    embeddingsBox = ObjectBox.instance.store.box<EmbeddingEntity>();
    documents = widget.group.documents;
    transformerFuture = initSentenceTransformer();
  }
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridContainer(
          color: backgroundColor.of(theme),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.group.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final result = await changeNameDialog(context, widget.group);
                  if (result != null && result.isNotEmpty && context.mounted) {
                    final provider = Provider.of<KnowledgeBaseProvider>(context, listen: false);
                    provider.renameGroup(widget.group, result);
                  }
                },
                icon: const Icon(FluentIcons.edit, size: 16)
              )
            ],
          ),
        ),
        Expanded(
          child: GridContainer(
            color: backgroundColor.of(theme),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: DropArea(
                type: "a document or folder",
                showChild: documents.isNotEmpty,
                onUpload: (files) => processUpload(context, files),
                child: Column(
                  children: [
                    for (final document in documents)
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
            ),
          ),
        ),
      ],
    );
  }
}
