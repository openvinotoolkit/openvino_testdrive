import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/blocks/block_extensions.dart';
import 'package:inference/pages/workflow/blocks/block.dart';
import 'package:inference/pages/workflow/blocks/model.dart';
import 'package:inference/pages/workflow/utils/assets.dart';
import 'package:inference/pages/workflow/utils/data.dart';
import 'package:inference/pages/workflow/widgets/inspector/model.dart';

class Inspector extends StatefulWidget {
  final WorkflowBlock? element;
  final List<Model> models;
  const Inspector({required this.element, required this.models, super.key});

  @override
  State<Inspector> createState() => _InspectorState();
}

class _InspectorState extends State<Inspector> {
  final TextEditingController _nameController = TextEditingController();
  WorkflowBlock? element;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.element?.name ?? "";
    element = widget.element;
  }
  @override
  void didUpdateWidget(covariant Inspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      _nameController.text = widget.element?.name ?? "";
      element = widget.element; // set state?
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Builder(
          builder: (context) {
            if (element == null) {
              // Show generic info
              return Container();
            }
            final block = element!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: "Type:",
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: ComboBox(
                      value: block.type?.type.name,
                      items: BlockType.values.map<ComboBoxItem<String?>>((e) {
                        return ComboBoxItem<String>(
                          value: e.name,
                          child: Text(e.name.uppercaseFirst())
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v is String) {
                          setState(() {
                            block.type = BlockTypeExtension.fromName(v)?.createBlock();
                          });
                        }
                      },
                    ),
                  )
                ),
                SizedBox(height: 10),
                InfoLabel(
                  label: "Name:",
                  child: TextBox(
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        block.name = value;
                        final width = max(WorkflowBlock.calculateBlockWidth(value), WorkflowBlock.calculateBlockWidth(block.type?.name ?? "Type"));
                        block.dimensions = Rect.fromLTWH(
                          block.dimensions.left,
                          block.dimensions.top,
                          width,
                          block.dimensions.height
                        );
                      }
                    },
                    controller: _nameController,
                  )
                ),
                SizedBox(height: 10),
                inspector(),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget inspector () {
    if (element == null) {
      return Container();
    }
    return switch(element?.type?.type) {
      BlockType.model => ModelInspector(
        availableModels: widget.models,
        element: element!.type as ModelBlock,
      ),
      _ => Container(),
    };
  }
}
