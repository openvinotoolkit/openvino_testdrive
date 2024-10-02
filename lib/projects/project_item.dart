import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:inference/theme.dart';
import 'package:inference/color.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum MenuButtons { delete }

class ProjectItem extends StatefulWidget {
  final Project project;
  const ProjectItem(this.project, {super.key});

  @override
  State<ProjectItem> createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem> {
  final DateFormat formatter = DateFormat('dd MMMM y | h:mm a');
  bool hovered = false;

  void onHover(bool? val) {
    setState(() {
      hovered = val ?? false;
    });
  }

  Color backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (hovered) {
      return scheme.onSurfaceVariant;
    } else {
      return scheme.surfaceContainer;
    }
  }

  void onTap(Project project) async {
    if (project.isPublic || project.loaded.isCompleted) {
      goToProject(project);
    }
  }

  void goToProject(Project project) {
    // uncomment this to check the other downloading style...
    //if (project.isDownloaded) { // or something.
    context.go('/inference', extra: project);
    //} else {
    //  createDirectory(project as PublicProject);
    //  writeProjectJson(project);

    //  Provider.of<DownloadProvider>(context, listen: false).queue(llmDownloadFiles(project)).then((_) {
    //     getAdditionalModelInfo(project).then((_) {
    //        Provider.of<ProjectProvider>(context, listen: false).completeLoading(project);
    //     });
    //  });
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Consumer<ProjectProvider>(builder: (context, projects, child) {
            return InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onHover: (val) => onHover(val),
                  onTap: () => onTap(widget.project),
                  child: Opacity(
                    opacity: (widget.project is PublicProject ||
                            widget.project.loaded.isCompleted
                        ? 1.0
                        : 0.5),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints.expand(height: 136),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 288,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: widget.project.thumbnailImage(),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: backgroundColor(context),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(widget.project.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    )),
                                                Text(" @ ${widget.project.taskName()}")
                                              ],
                                            ),
                                            (widget.project.isDownloaded
                                                ? Row(
                                                    children: [
                                                      (widget.project is GetiProject && widget.project.type != ProjectType.text
                                                        ? Row(children: (widget.project as GetiProject)
                                                            .scores()
                                                            .map((p) {
                                                              if (p == null) {
                                                                return Container();
                                                              }
                                                              return ScoreItem(p);
                                                          }).toList())
                                                        : Container()),
                                                      PopupMenuButton(
                                                        iconColor: textColor,
                                                        iconSize: 16,
                                                        onSelected: (MenuButtons _) => projects.removeProject(widget .project),
                                                        color: intelGrayDark,
                                                        elevation: 1,
                                                        itemBuilder: (BuildContext context) {
                                                          return <PopupMenuEntry<MenuButtons>>[
                                                            const PopupMenuItem<MenuButtons>(
                                                              value: MenuButtons .delete,
                                                              child: Text('Delete'),
                                                            ),
                                                          ];
                                                        },
                                                      )
                                                    ],
                                                  )
                                                : Container())
                                          ],
                                        ),
                                        Text(
                                            "Created: ${formatter.format(DateTime.parse(widget.project.creationTime))}"),
                                        const Divider(color: intelGrayLight),
                                        Row(
                                            children: (widget.project.labels().length > 4
                                              ? [
                                                  ...(widget.project
                                                          .labels()
                                                          .sublist(0, 4))
                                                      .map((label) =>
                                                          LabelItem(label)),
                                                  const Text("   ...and more")
                                                ]
                                                : widget.project
                                                    .labels()
                                                    .map((label) =>
                                                        LabelItem(label))
                                                    .toList()))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              );
          })),
    );
  }
}

class ScoreItem extends StatelessWidget {
  final Score score;
  const ScoreItem(this.score, {super.key});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    return SizedBox(
      width: 40,
      child: Column(children: [
        Text(NumberFormat.percentPattern(locale.languageCode)
            .format(score.score)),
        Padding(
          padding: const EdgeInsets.only(left: 7.0, right: 7.0),
          child: Stack(
            children: [
              const Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
              SizedBox(
                  width: (score.score * (26)),
                  child: Divider(
                      color: getScoreColor(score.score),
                      height: 2,
                      thickness: 2)),
            ],
          ),
        )
      ]),
    );
  }
}

class LabelItem extends StatelessWidget {
  final Label label;
  const LabelItem(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                color: HexColor.fromHex(label.color.substring(0, 7)),
                width: 10,
                height: 10,
              )),
        ),
        Text(label.name),
      ],
    );
  }
}
