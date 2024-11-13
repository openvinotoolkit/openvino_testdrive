import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/models/widgets/model_property.dart';
import 'package:inference/project.dart';
import 'package:inference/widgets/elevation.dart';

class ModelCard extends StatefulWidget {
  final Project project;
  const ModelCard({super.key, required this.project});

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 2, end: 8).animate(controller)..addListener(() {
      setState(() {});
    });
    controller.reset();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return GestureDetector(
      onTap: () => GoRouter.of(context).go("/models/inference", extra: widget.project),
      child: MouseRegion(
        onEnter: (_) => controller.forward(),
        onExit: (_) => controller.reverse(),
        cursor: SystemMouseCursors.click,
        child: Elevation(
          backgroundColor: theme.cardColor,
          elevation: animation.value,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: theme.brightness.isDark
                ? Border.all(
                  color: theme.shadowColor,
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ModelProperty(name: "Task", value: widget.project.taskName()),
                              ModelProperty(name: "Architecture", value: widget.project.architecture),
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
