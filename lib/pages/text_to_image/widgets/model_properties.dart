import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/text_to_image/providers/text_to_image_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/utils.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ModelProperties extends StatelessWidget {
  const ModelProperties({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TextToImageInferenceProvider>(builder: (context, inference, child) {
        Locale locale = Localizations.localeOf(context);
        final formatter = NumberFormat.percentPattern(locale.languageCode);

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
                        title: "Task",
                        value: inference.project!.taskName(),
                      ),
                      ModelProperty(
                        title: "Architecture",
                        value: inference.project!.architecture,
                      ),
                      ModelProperty(
                        title: "Size",
                        value: inference.project!.size?.readableFileSize() ?? "",
                      ),
                      Builder(
                        builder: (context) {
                          if (inference.project!.tasks.first.performance == null) {
                            return Container();
                          }
                          return ModelProperty(
                            title: "Accuracy",
                            value: formatter.format(inference.project!.tasks.first.performance!.score)
                          );
                        }
                      ),
                    ],
                  ),
                )
              ],
            )
          ),
        );
      }
    );
  }
}

class ModelProperty extends StatelessWidget {
  final String title;
  final String value;

  const ModelProperty({
      required this.title,
      required this.value,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(title, style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(value, style: TextStyle(
              fontSize: 16,
              color: subtleTextColor.of(theme),
          )),
        ),
      ]
    );
  }
}
