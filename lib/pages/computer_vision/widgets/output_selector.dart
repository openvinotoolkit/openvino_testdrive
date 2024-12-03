import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/providers/batch_inference_provider.dart';
import 'package:provider/provider.dart';

class OutputSelector extends StatefulWidget {
  const OutputSelector({super.key});

  @override
  State<OutputSelector> createState() => _OutputSelectorState();
}

class _OutputSelectorState extends State<OutputSelector> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Consumer<BatchInferenceProvider>(builder: (context, batchInference, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text("Outputs",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            OutputToggle(
              name: "Overlay image",
              initialValue: batchInference.output.overlay,
              onToggle: (v) {
                setState(() {
                    batchInference.output = batchInference.output..overlay = v;
                });
              },
            ),
            OutputToggle(
              name: "CSV",
              initialValue: batchInference.output.csv,
              onToggle: (v) {
                setState(() {
                    batchInference.output = batchInference.output..csv = v;
                });
              },
            ),
            OutputToggle(
              name: "JSON",
              initialValue: batchInference.output.json,
              onToggle: (v) {
                setState(() {
                    batchInference.output = batchInference.output..json = v;
                });
              },
            ),
          ],
        );
      }
    );
  }
}

class OutputToggle extends StatefulWidget {
  final String name;
  final bool initialValue;
  final Function(bool)? onToggle;

  const OutputToggle({
      super.key,
      required this.name,
      this.onToggle,
      this.initialValue = false,
  });

  @override
  State<OutputToggle> createState() => _OutputToggleState();
}

class _OutputToggleState extends State<OutputToggle> {
  late bool checked;

  @override
  void initState() {
    super.initState();
    checked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.name),
          ToggleSwitch(
            checked: checked,
            onChanged: (bool val) {
              setState(() {
                  checked = val;
                  widget.onToggle?.call(val);
              });
            },
          )
        ]
      ),
    );
  }
}
