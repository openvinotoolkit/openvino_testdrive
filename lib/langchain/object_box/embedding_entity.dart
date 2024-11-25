import 'package:objectbox/objectbox.dart';

@Entity()
class EmbeddingEntity {
  @Id()
  int id = 0;

  String? text;

  @HnswIndex(dimensions: 384)
  @Property(type: PropertyType.floatVector)
  List<double>? embeddings;

  EmbeddingEntity(this.text, this.embeddings);
}
