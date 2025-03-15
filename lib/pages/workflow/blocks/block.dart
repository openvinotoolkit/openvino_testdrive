import 'package:fluent_ui/fluent_ui.dart';

enum BlockType {
  crop,
  image,
  model,
}

abstract class WorkflowBlockBase {
  final BlockType type;

  String get name => type.name.uppercaseFirst();

  WorkflowBlockBase(this.type);
}
