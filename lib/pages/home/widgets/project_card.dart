import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/project.dart';
import 'package:inference/widgets/elevation.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({required this.project, super.key});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 300, minWidth: 200),
      child: Elevation(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 4.0,
        child: Card(
          borderColor: theme.cardColor,
          child: Center(
            child: Text(project.name),
        ),
        ),
      ),
    );
  }
}
