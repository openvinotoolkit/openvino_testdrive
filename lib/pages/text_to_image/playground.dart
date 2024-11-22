import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/pages/text_to_image/providers/text_to_image_inference_provider.dart';
import 'package:inference/project.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/device_selector.dart';
import 'package:provider/provider.dart';

class Playground extends StatefulWidget {
  final Project project;
  const Playground({super.key, required this.project});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: GridContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const DeviceSelector(),
                      ],
                    ),
                  ),
                ),
              ),
              Consumer<TextToImageInferenceProvider>(
                builder: (context, inference, child) {
                  return Expanded(
                    child: Builder(
                      builder: (context) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: GridContainer(
                                color: backgroundColor.of(theme),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  );
                }
              )
            ],
          ),
        ),
        ModelProperties(project: widget.project),
      ]
    );
  }
}
