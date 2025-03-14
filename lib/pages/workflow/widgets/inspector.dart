import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/utils/data.dart';

class Inspector extends StatefulWidget {
  final WorkflowBlock? element;
  const Inspector({required this.element, super.key});

  @override
  State<Inspector> createState() => _InspectorState();
}

class _InspectorState extends State<Inspector> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.element?.name ?? "";
  }
  @override
  void didUpdateWidget(covariant Inspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      _nameController.text = widget.element?.name ?? "";
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
            if (widget.element == null) {
              // Show generic info
              return Container();
            }
            final block = widget.element!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: "Type:",
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(block.type),
                  )
                ),
                SizedBox(height: 10),
                InfoLabel(
                  label: "Name:",
                  child: TextBox(
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        block.name = value;
                        final width = max(WorkflowBlock.calculateBlockWidth(value), WorkflowBlock.calculateBlockWidth(block.type));
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
              ],
            );
          }
        ),
      ),
    );
  }
}
