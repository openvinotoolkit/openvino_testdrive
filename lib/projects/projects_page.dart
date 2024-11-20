import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/config.dart';
import 'package:inference/header.dart';
import 'package:inference/importers/importer.dart';
import 'package:inference/project.dart';
import 'package:inference/projects/task_type_filter.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/searchbar.dart';
import 'package:inference/projects/project_item.dart';
import 'package:inference/theme.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectsPage> with TickerProviderStateMixin {
  void showErrorDialog(String error, String stack) {
      showDialog(context: context, builder: (BuildContext context) => AlertDialog(
            title: Text('A critical error occured: $error'),
            content: Text(stack),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ]
          )
      );
  }

  @override
  void initState() {
    super.initState();

    // FlutterError.onError = (details) {
    //   FlutterError.presentError(details);
    //   //showErrorDialog(details.exception.toString(), details.stack.toString());
    // };
    //PlatformDispatcher.instance.onError = (error, stack) {
    //  showErrorDialog(error.toString(), stack.toString());
    //  return true;
    //};
  }

  void addProject(BuildContext context) async {

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      for (final file in result.files) {
        final importer = selectMatchingImporter(file.path!);
        if (importer == null) {
          print("unable to process file");
          return;
        }
        if (context.mounted) {
          if (!await importer.askUser(context)) {
            print("cancelling due to user input");
            return;
          }
        }
        importer.generateProject().then((project) async {
          await importer.setupFiles();
          project.loaded.future.then((_) {
            if (context.mounted) {
              Provider.of<ProjectProvider>(context, listen: false)
                  .completeLoading(project);
            }
          });
          if (context.mounted) {
            final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
            projectsProvider.addProject(project);
          }
        });
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectFilterProvider(),
      child: Scaffold(
          appBar: const Header(false),
          body: Consumer<ProjectProvider>(builder: (context, projects, child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Consumer<ProjectFilterProvider>(builder: (context, filter, child) {
                final selectedProjects = filter.applyFilter(projects.projects);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetiSearchBar(
                            onChange: (value) => filter.name = value,
                          ),
                          (Config.geti
                            ? ElevatedButton(
                              onPressed: () => addProject(context),
                              child: const Text("Import Model")
                            )
                            : ImportModelButton(
                              onHuggingFace: () => context.go("/import"),
                              onLocal: () => addProject(context),
                            )
                          )
                        ]),
                      ),
                      Expanded(
                        child: GetiProjectsList(selectedProjects.toList())
                      )
                    ]
                  );
              }),
            );
          })),
    );
  }
}

enum MenuButtons { huggingface, local }

class ImportModelButton extends StatelessWidget {
  final Function() onHuggingFace;
  final Function() onLocal;
  const ImportModelButton({required this.onHuggingFace, required this.onLocal, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (MenuButtons btn) {
        switch(btn.name) {
          case "huggingface": onHuggingFace();
          case "local": onLocal();
          default: throw UnimplementedError();
        }
      },
      offset: const Offset(0, 40),
      color: intelGrayVariant,
      elevation: 20,
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<MenuButtons>>[
          PopupMenuItem<MenuButtons>(
            value: MenuButtons.huggingface,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SvgPicture.asset('images/hf-logo.svg', width: 18),
                ),
                const Text('Huggingface'),
              ],
            ),
          ),
          const PopupMenuItem<MenuButtons>(
            value: MenuButtons.local,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.folder_open, color: Color.fromRGBO(248, 212, 78, 1.0), size: 18),
                ),
                Text('Local disk'),
              ],
            ),
          ),
        ];
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: intelBlueVibrant,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
          child: const Text("Import Model",
            style: TextStyle(
              color: Colors.white
            ),
          ),
        )
      ),
    );
  }

}

class GetiProjectsList extends StatelessWidget {
  final List<Project> projects;
  const GetiProjectsList(this.projects, {super.key});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
     return Center(
       child: SizedBox(
         height: 450,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.start,
           children: [
             SvgPicture.asset('images/upload_art.svg'),
             const Text("No imported models", style: TextStyle(
                 fontSize: 20,
             )),
             const Text("Import a Geti deployment using the import model button")
           ],
         ),
       )
     );
  }

  return SingleChildScrollView(
      child: Column(
          children: projects.map((project) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ProjectItem(project),
            );
          }).toList()
      )
    );
  }
}

class PublicProjectsList extends StatelessWidget {
  final List<Project> projects;
  final bool publicLoaded;
  const PublicProjectsList(this.projects, this.publicLoaded, {super.key});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
     return Container();
  }

  return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...projects.map((project) => ProjectItem(project)),
          ...(publicLoaded
            ? [Container()]
            : [
                const GhostProjectItem(),
                const GhostProjectItem(),
                const GhostProjectItem()
              ]
          )
        ]
      )
    );
  }
}

class GhostProjectItem extends StatelessWidget {
  const GhostProjectItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Opacity(
          opacity: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(height: 136),
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surface,
                highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                )
            ),
          ),
        )
      )
    );
  }
}
