import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/importers/manifest_importer.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final showDescription = constraints.maxHeight > 300;
        return GestureDetector(
          onTap: () { onChecked(!checked); },
          child: Elevation(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: checked ? 16 : 4,
            child: AnimatedContainer(
              curve: theme.animationCurve,
              duration: theme.mediumAnimationDuration,
              decoration: BoxDecoration(
                color: checked ? theme.inactiveBackgroundColor.withOpacity(0.5) : theme.cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 5 / 2,
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            model.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (showDescription)
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.micaBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Optimization: ',
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: model.optimizationPrecision,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.micaBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Size: ',
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: model.readableFileSize,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.micaBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(model.task, style: const TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
