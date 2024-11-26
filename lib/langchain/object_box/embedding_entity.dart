import 'package:objectbox/objectbox.dart';

@Entity()
class KnowledgeGroup {
  @Id()
  int internalId = 0;

  String name;

  KnowledgeGroup(
    this.name,
  );
}

@Entity()
class KnowledgeDocument {
  @Id()
  int internalId = 0;

  String source;

  final group = ToOne<KnowledgeGroup>();

  KnowledgeDocument(
    this.internalId,
    this.source,
  );
}

@Entity()
class EmbeddingEntity {
  @Id()
  int internalId = 0;

  @Unique(onConflict: ConflictStrategy.replace)
  String id;

  /// The content of the document.
  String content;

  /// The metadata of the document.
  String metadata;

  @HnswIndex(dimensions: 384)
  @Property(type: PropertyType.floatVector)
  List<double> embeddings;

  final document = ToOne<KnowledgeDocument>();

  EmbeddingEntity(
    this.id,
    this.content,
    this.metadata,
    this.embeddings,
  );
}
