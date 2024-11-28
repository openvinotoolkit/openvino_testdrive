import 'package:flutter/widgets.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ModelProperties extends StatelessWidget {
  const ModelProperties({super.key});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
      locale: locale.languageCode, decimalDigits: 2);

    return Consumer<TextInferenceProvider>(builder: (context, inference, child) {
      return SizedBox(
        width: 280,
        child: GridContainer(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Model parameters", style: TextStyle(
                  fontSize: 20,
              )),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModelProperty(
                      title: "Model name",
                      value: inference.project!.name,
                    ),
                    ModelProperty(
                      title: "Architecture",
                      value: inference.project!.architecture,
                    ),
                    ModelProperty(
                      title: "Temperature",
                      value: nf.format(inference.temperature),
                    ),
                    ModelProperty(
                      title: "Top P",
                      value: nf.format(inference.topP),
                    ),
                  ]
                )
              ),
            ]
          )
        )
      );
  });
  }
}