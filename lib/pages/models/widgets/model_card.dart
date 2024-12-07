import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/models/widgets/model_property.dart';
import 'package:inference/project.dart';
import 'package:inference/utils.dart';
import 'package:inference/widgets/elevation.dart';
import 'package:intl/intl.dart';

class ModelCard extends StatefulWidget {
  final Project project;
  const ModelCard({super.key, required this.project});

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard>{
  bool isHovered = false;

    @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onTap: () {
        if (widget.project.isDownloaded) {
          GoRouter.of(context).go("/models/inference", extra: widget.project);
        } else {
          GoRouter.of(context).go("/models/download", extra: widget.project);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Elevation(
          backgroundColor: theme.cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: theme.brightness.isDark
                ? Border.all(
                  color: const Color(0xFF464646),
                  width: 1,
                )
                : null,
              color: theme.cardColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 5/4,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: widget.project.thumbnailImage(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.project.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ModelProperty(name: "Task", value: widget.project.taskName()),
                              ModelProperty(name: "Architecture", value: widget.project.architecture),
                              Row(
                                children: [
                                  ModelProperty(name: "Size", value: widget.project.size?.readableFileSize() ?? ""),
                                  Builder(
                                    builder: (context) {
                                      if (widget.project is GetiProject && widget.project.tasks.first.performance != null) {
                                        Locale locale = Localizations.localeOf(context);
                                        final formatter = NumberFormat.percentPattern(locale.languageCode);
                                        return ModelProperty(
                                          name: "Accuracy",
                                          value: formatter.format(widget.project.tasks.first.performance!.score));
                                      }
                                      return Container();
                                    }
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
