import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/widgets/elevation.dart';
import 'package:provider/provider.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({required this.project, super.key});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Elevation(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 4.0,
      child: Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        children: [
        Expanded(
          flex: 1,
            child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            child: Stack(
              children: [
              Container(
                decoration: BoxDecoration(
                image: DecorationImage(
                  image: project.thumbnailImage(),
                  fit: BoxFit.cover,
                ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  color: theme.menuColor,
                ),
                child: Text(project.type.name),
                ),
              ),
              ],
            ),
            ),
        ),
        Expanded(
          flex: 1,
          child: Row(
          children: [
            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                project.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text(
                'Some description',
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(onPressed: () {}, child: const Row(children: [
                      Icon(FluentIcons.pop_expand,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Open'),
                      )
                    ],)),
                    Consumer<ProjectProvider>(builder: (context, value, child) => DropDownButton(
                      items: [
                        MenuFlyoutItem(text: const Text('Delete'), onPressed: () { value.removeProject(project); })
                      ],
                      buttonBuilder: (context, onOpen) => IconButton(icon: const Icon(FluentIcons.more), onPressed: onOpen),
                    ),)
                  ],
                ),
              )
              ],
            ),
            ),
          ],
          ),
        ),
        ],
      ),
      ),
    );
  }
}
