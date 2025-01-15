import 'dart:convert';

import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';
import 'package:langchain/langchain.dart';

class ObjectBoxStore  extends VectorStore {
  late Box<EmbeddingEntity> embeddingsBox;
  late KnowledgeGroup group;

  ObjectBoxStore({
    required super.embeddings,
    required this.group,
  }) {
    embeddingsBox = ObjectBox.instance.store.box<EmbeddingEntity>();
  }

  @override
  Future<List<String>> addVectors({
    required final List<List<double>> vectors,
    required final List<Document> documents,
  }) async {
    throw UnimplementedError("Read only VectorStore");
  }

  @override
  Future<void> delete({required final List<String> ids}) async {
    throw UnimplementedError("Read only VectorStore");
  }

  @override
  Future<List<(Document, double)>> similaritySearchByVectorWithScores({
    required final List<double> embedding,
    final VectorStoreSimilaritySearch config =
        const VectorStoreSimilaritySearch(),
  }) async {
    var filter =
        EmbeddingEntity_.embeddings.nearestNeighborsF32(embedding, config.k);

    final filterCondition = config.filter?.values.firstOrNull;
    if (filterCondition != null && filterCondition is Condition<EmbeddingEntity>) {
      filter = filter.and(filterCondition);
    }
    QueryBuilder<EmbeddingEntity> builder = embeddingsBox.query(filter);
    final documents = group.documents.map((p) => p.internalId).toList();
    builder.link(EmbeddingEntity_.document, KnowledgeDocument_.internalId.oneOf(documents));
    final query = builder.build();

    Iterable<ObjectWithScore<EmbeddingEntity>> results = query.findWithScores();

    if (config.scoreThreshold != null) {
      results = results.where((final r) => r.score >= config.scoreThreshold!);
    }
    print(results.map((p) => p.object.content));

    return results
        .map((r) => (Document(pageContent: r.object.content, metadata: jsonDecode(r.object.metadata)), r.score))
        .toList(growable: false);
  }
}
