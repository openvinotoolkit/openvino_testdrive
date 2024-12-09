import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/pages/models/widgets/model_property.dart';
import 'package:inference/widgets/elevation.dart';

class ModelCard extends StatelessWidget {
  final Model model;
  final bool checked;
  final ValueChanged<bool> onChecked;

  const ModelCard({
    required this.model,
    required this.checked,
    required this.onChecked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return GestureDetector(
      onTap: () { onChecked(!checked); },
      child: Elevation(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: AnimatedContainer(
          curve: theme.animationCurve,
          duration: theme.mediumAnimationDuration,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(
                color: checked ? theme.accentColor.withOpacity(0.5) : theme.cardColor,
                width: 1.0
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 7/4,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: model.thumbnail.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        model.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      model.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children: [
                    ModelProperty(name: "Optimization", value: model.optimizationPrecision),
                    ModelProperty(name: "Size", value: model.readableFileSize),
                    ModelProperty(name: "Task", value: model.task),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
