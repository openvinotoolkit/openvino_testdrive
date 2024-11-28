import 'dart:convert';

import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';
import 'package:langchain/langchain.dart';

//class EmbeddingEntityVectorStore extends BaseObjectBoxVectorStore<EmbeddingEntity> {
//  EmbeddingEntityVectorStore({
//    required super.embeddings,
//    required Store store,
//  }) : super(
//          box: store.box<EmbeddingEntity>(),
//          createEntity: (
//            String id,
//            String content,
//            String metadata,
//            List<double> embedding,
//          ) => EmbeddingEntity(id, content, metadata, embedding),
//          createDocument: (EmbeddingEntity docDto) {
//            return Document(
//              pageContent: docDto.content,
//              id: docDto.id,
//              metadata: jsonDecode(docDto.metadata),
//            );
//          },
//          getIdProperty: () => EmbeddingEntity_.id,
//          getEmbeddingProperty: () => EmbeddingEntity_.embeddings,
//        );
//}

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

    final documents = group.documents.map((p) => p.internalId).toList();
    print(documents);
    //filter = filter.and(EmbeddingEntity_.document.oneOf(documents));
    //print(filter);
    //print("applied filter");
    final query = embeddingsBox.query(filter).build();
    print(query);

    Iterable<ObjectWithScore<EmbeddingEntity>> results = query.findWithScores();

    if (config.scoreThreshold != null) {
      results = results.where((final r) => r.score >= config.scoreThreshold!);
    }
    print(results);

    return results
        .map((r) => (Document(pageContent: r.object.content, metadata: jsonDecode(r.object.metadata)), r.score))
        .toList(growable: false);
  }

}
