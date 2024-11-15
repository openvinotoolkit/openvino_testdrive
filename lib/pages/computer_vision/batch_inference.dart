 import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/widgets/folder_selector.dart';
import 'package:inference/pages/computer_vision/widgets/horizontal_rule.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';

class BatchInference extends StatefulWidget {
  const BatchInference({super.key});

  @override
  State<BatchInference> createState() => _BatchInferenceState();
}

class _BatchInferenceState extends State<BatchInference> {
  String sourceFolder = "";
  String destinationFolder = "";

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 720,
                ),
                child: Column(
                  children: [
                    FolderSelector(
                      label: "Source folder",
                      onSubmit: (String file) => setState(() {
                            sourceFolder = file;
                      }),
                    ),
                    const HorizontalRule(),
                    FolderSelector(
                      label: "Destination folder",
                      onSubmit: (String file) => setState(() {
                            destinationFolder = file;
                      }),
                    ),
                    const HorizontalRule(),
                  ],
                ),
              ),
            ),
          ),
        ),
        const ModelProperties(),
      ],
    );
  }
}
