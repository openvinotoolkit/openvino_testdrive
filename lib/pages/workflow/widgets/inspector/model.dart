import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/blocks/model.dart';
import 'package:inference/pages/workflow/utils/assets.dart';

class ModelInspector extends StatelessWidget {
  final List<Model> availableModels;
  final ModelBlock element;

  const ModelInspector({
      required this.availableModels,
      required this.element,
      super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InfoLabel(
          label: "Model",
          child: ComboBox(
            value: element.model,
            items: availableModels.map<ComboBoxItem<Model?>>((e) {
              return ComboBoxItem<Model>(
                value: e,
                child: Text(e.name)
              );
            }).toList(),
            onChanged: (v) {
              element.model = v;
            },
          ),
        ),
      ],
    );
  }

}
