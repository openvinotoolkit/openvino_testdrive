// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/sentence_transformer.dart';
import 'package:inference/pages/models/widgets/searchbar.dart';
import 'package:inference/utils.dart';
import 'package:inference/langchain/all_mini_lm_v6.dart';
import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';
import 'package:inference/pages/knowledge_base/utils/loader_selector.dart';
import 'package:inference/pages/knowledge_base/widgets/change_name_dialog.dart';
import 'package:inference/pages/knowledge_base/widgets/import_dialog.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/controls/drop_area.dart';
import 'package:langchain/langchain.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' show basename;
import 'package:uuid/uuid.dart';

class DocumentsList extends StatefulWidget {
  final KnowledgeGroup group;
  const DocumentsList({super.key, required this.group});

  @override
  State<DocumentsList> createState() => _DocumentsListState();
}

class _DocumentsListState extends State<DocumentsList> {
  late Box<KnowledgeGroup> groupBox;
  late Box<KnowledgeDocument> documentBox;
  late Box<EmbeddingEntity> embeddingsBox;
  late String groupName;
  Future<SentenceTransformer>? transformerFuture;

  bool listOrder = false;

  Map<String, BaseDocumentLoader>? filesToImport;

  String? search;
  late Stream<Query<KnowledgeDocument>> documentStream;

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

  void processUpload(BuildContext context, List<String> paths) {
    importDialog(context, paths).then(processNewFiles);
  }

  Future<void> processNewFiles(List<String> files) async {
    for (final file in files){
      final loader = loaderFromPath(file);
      if (loader != null) {
        final newDocument = await addDocument(file, loader);
        setState(() {
          widget.group.documents.add(newDocument);
        });
      }
    }
  }

  void removeDocument(KnowledgeDocument document) {
    documentBox.remove(document.internalId);
  }

  @override
  void initState() {
    super.initState();
    groupBox = ObjectBox.instance.store.box<KnowledgeGroup>();
    documentBox = ObjectBox.instance.store.box<KnowledgeDocument>();
    embeddingsBox = ObjectBox.instance.store.box<EmbeddingEntity>();
    transformerFuture = initSentenceTransformer();

    //caching via state since widget does not (need) updating on name change.
    groupName = widget.group.name;

    documentStream = documentBox.query(KnowledgeDocument_.group.equals(widget.group.internalId)).watch(triggerImmediately: true);
  }

  Future<void> selectDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: supportedExtensions);
    if (result != null && mounted) {
      processNewFiles(result.files.map((file) => file.path).whereType<String>().toList());
    }
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
                child: Text(groupName,
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
                    groupBox.put(widget.group..name = result);
                    setState(() {
                        groupName = result;
                    });
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
            padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 25),
            child: StreamBuilder<Query<KnowledgeDocument>>(
              stream: documentStream,
              builder: (context, snapshot) {
                if(!snapshot.hasData) {
                  return Container();
                }
                final documents = (snapshot.data?.find() ?? []);
                var filteredDocuments = documents.where((doc) => basename(doc.source.toLowerCase()).contains(search?.toLowerCase() ?? "")).toList();
                if (listOrder) {
                  filteredDocuments = filteredDocuments.reversed.toList();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SearchBar(
                            onChange: (val) => setState(() => search = val),
                            placeholder: "Find file",
                          ),
                          FilledButton(
                            onPressed: selectDocuments,
                            child: Row(
                              children: [
                                const Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(FluentIcons.upload),
                                ),
                                const Text("Upload"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: DropArea(
                        type: "a document or folder",
                        showChild: documents.isNotEmpty,
                        onUpload: (files) => processUpload(context, files),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 10),
                          child: Table(
                            columnWidths: const <int, TableColumnWidth>{
                              0: FixedColumnWidth(20),
                              1: FlexColumnWidth(),
                              2: FlexColumnWidth(),
                              3: FlexColumnWidth(),
                              4: FixedColumnWidth(24),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: borderColor.of(theme),
                                      width: 1,
                                    )
                                  )
                                ),
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Name"),
                                        if (listOrder)
                                          IconButton(
                                            icon: const Icon(FluentIcons.chevron_down, size: 9),
                                            onPressed: () => setState(() => listOrder = false),
                                          )
                                        else
                                          IconButton(
                                            icon: const Icon(FluentIcons.chevron_up, size: 9),
                                            onPressed: () => setState(() => listOrder = true),
                                          )
                                      ],
                                    ),
                                  ),
                                  const TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Text("Kind"),
                                  ),
                                  const TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Text("Size"),
                                  ),
                                  Container(),
                                ],
                              ),

                              for (final document in filteredDocuments)
                                TableRow(
                                  children: <Widget>[
                                    Container(
                                      height: 32,
                                    ),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Text(basename(document.source))
                                    ),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Text(lookupMimeType(document.source) ?? "")
                                    ),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Text(File(document.source).statSync().size.readableFileSize()),
                                    ),
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: IconButton(
                                        icon: const Icon(FluentIcons.delete, size: 10),
                                        onPressed: () => removeDocument(document),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}
