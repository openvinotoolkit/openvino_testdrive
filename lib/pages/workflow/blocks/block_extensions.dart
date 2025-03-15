import 'package:inference/pages/workflow/blocks/block.dart';
import 'package:inference/pages/workflow/blocks/crop.dart';
import 'package:inference/pages/workflow/blocks/image.dart';
import 'package:inference/pages/workflow/blocks/model.dart';

extension BlockTypeExtension on BlockType {
  //String get displayName => name; // Enum name is already a string

  static BlockType? fromName(String name) {
    return BlockType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError("Invalid BlockType: $name"),
    );
  }
}

extension BlockTypeFactory on BlockType {
  WorkflowBlockBase createBlock() {
    return switch (this) {
      BlockType.crop => CropBlock(),
      BlockType.image => ImageBlock(),
      BlockType.model => ModelBlock(),
    };
  }
}
