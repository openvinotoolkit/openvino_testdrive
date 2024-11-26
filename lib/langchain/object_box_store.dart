import 'package:inference/langchain/object_box/embedding_entity.dart';
import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/objectbox.g.dart';
import 'package:langchain/langchain.dart';

//class ObjectBoxStore  extends VectorStore {
//  late Box<EmbeddingEntity> embeddingsBox;
//
//  ObjectBoxStore({
//    required super.embeddings,
//  }) {
//    embeddingsBox = ObjectBox.instance.store.box<EmbeddingEntity>();
//  }
//
//  @override
//  Future<List<String>> addVectors({
//    required final List<List<double>> vectors,
//    required final List<Document> documents,
//  }) async {
//    final embeddedDocs = await embeddings.embedDocuments(documents);
//    final newEmbeddings = [
//      for (int i = 0; i < documents.length; i++)
//        EmbeddingEntity(
//          documents[i].pageContent, embeddedDocs[i])
//    ];
//
//    return embeddingsBox.putManyAsync(newEmbeddings);
//    //memoryVectors.addAll(
//    //  vectors.mapIndexed((final i, final vector) {
//    //    final doc = documents[i];
//    //    return MemoryVector(
//    //      document: doc,
//    //      embedding: vector,
//    //    );
//    //  }),
//    //);
//    return const [];
//  }
//
//  @override
//  Future<void> delete({required final List<String> ids}) async {
//    //memoryVectors.removeWhere(
//    //  (final vector) => ids.contains(vector.document.id),
//    //);
//  }
//
//  @override
//  Future<List<(Document, double)>> similaritySearchByVectorWithScores({
//    required final List<double> embedding,
//    final VectorStoreSimilaritySearch config =
//        const VectorStoreSimilaritySearch(),
//  }) async {
//
//  }
//
//}
