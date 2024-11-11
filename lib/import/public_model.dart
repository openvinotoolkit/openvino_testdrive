import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inference/import/optimization_filter_button.dart';
import 'package:inference/projects/task_type_filter.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_model_info.dart';
import 'package:inference/public_models.dart';
import 'package:inference/searchbar.dart';
import 'package:inference/theme.dart';
import 'package:inference/utils/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

class PublicModelPage extends StatefulWidget {
  const PublicModelPage({super.key});

  @override
  State<PublicModelPage> createState() => _PublicModelPageState();
}

class _PublicModelPageState extends State<PublicModelPage> {
  List<PublicModelInfo>? models;

  PublicModelInfo? selectedModelForImport;

  void loadModels() async {
    try {
    final publicModels = await getPublicModels();
    setState(() {
      models = publicModels;
    });
  } on DioException catch(ex) {
    if (ex.type == DioExceptionType.connectionError) {
      if (context.mounted) {
        errorDialog(context, "Connection error","Unable to connect to HuggingFace to load the OpenVINO model collections.\nPlease disable your proxy or VPN and try again.");
      }
    }
  }

  }

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  List<Widget> buildList(ProjectFilterProvider filter) {
    if (models == null) {
      return const [
         GhostProjectItem(),
         GhostProjectItem(),
         GhostProjectItem(),
         GhostProjectItem(),
         GhostProjectItem(),
         GhostProjectItem(),
         GhostProjectItem(),
         GhostProjectItem(),
      ];
    }

    final filteredModels = filter.applyFilterOnPublicModelInfo(models!);

    return filteredModels.map((model) {
        return PublicModelItem(model,
          key: ValueKey(model),
          isSelected: selectedModelForImport == model,
          onToggle: (selected) {
            setState(() {
              if (selected) {
                selectedModelForImport = model;
              } else {
                selectedModelForImport = null;
              }
            });
          },
        );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectFilterProvider(),
      child: Consumer<ProjectFilterProvider>(builder: (context, filter, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3, bottom: 8.0, top: 8.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GetiSearchBar(
                              onChange: (value) => filter.name = value,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 32.0),
                              child: Text("Optimization: "),
                            ),
                            OptimizationFilterButton("int4", filter),
                            OptimizationFilterButton("int8", filter),
                            OptimizationFilterButton("fp16", filter),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                          primary: false,
                          slivers: <Widget>[
                            SliverPadding(
                              padding: const EdgeInsets.all(3),
                              sliver: SliverGrid.extent(
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                maxCrossAxisExtent: 310,
                                childAspectRatio: 1.5,
                                children: buildList(filter)
                              )
                            )
                          ]
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton(
                                style: const ButtonStyle(
                                  elevation: WidgetStatePropertyAll(0),
                                  backgroundColor: WidgetStatePropertyAll(intelGray)
                                ),
                                onPressed: () {
                                  setState(() {
                                    context.pop();
                                  });
                                },
                                child: const Text("Cancel")
                              ),
                            ),

                            ElevatedButton(
                              style: ButtonStyle(
                                elevation: const WidgetStatePropertyAll(0),
                                backgroundColor: (selectedModelForImport == null
                                  ? const WidgetStatePropertyAll(intelGray)
                                  : null
                                )
                              ),
                              onPressed: () {
                                if (selectedModelForImport != null) {
                                  final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
                                  PublicModelInfo.convertToProject(selectedModelForImport!).then((project) {
                                    projectsProvider.addProject(project);
                                    context.go('/inference', extra: project);
                                  });
                                }
                              },
                              child: const Text("Add model")
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}


class GhostProjectItem extends StatelessWidget {
  const GhostProjectItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
    );
  }
}

class PublicModelItem extends StatefulWidget {
  final PublicModelInfo model;
  final Function onToggle;
  final bool isSelected;
  const PublicModelItem(this.model, {required this.onToggle, this.isSelected = false, super.key});

  @override
  State<PublicModelItem> createState() => _PublicModelItemState();
}

class _PublicModelItemState extends State<PublicModelItem> {
  bool hovered = false;

  void onHover(bool? val) {
    setState(() {
      hovered = val ?? false;
    });
  }

  void onTap() {
    widget.onToggle(!widget.isSelected);
  }

  Color backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (hovered) {
      return scheme.onSurfaceVariant;
    } else {
      return scheme.surface;
    }
  }

  Color borderColor(BuildContext context) {
    if (widget.isSelected) {
      return intelBlue;
    } else {
      return backgroundColor(context);
    }
  }

  double borderWidth(BuildContext context) {
    if (widget.isSelected) {
      return 2;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(width: borderWidth(context), color: borderColor(context))
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            splashFactory: NoSplash.splashFactory,
            borderRadius: BorderRadius.circular(8.0),
            onHover: (val) => onHover(val),
            onTap: () => onTap(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: widget.model.thumbnail.image,
                        fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.model.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )
                        ),
                        //Text(formatter.format(DateTime.parse(widget.model.lastModified))),
                        //Column(
                        //  crossAxisAlignment: CrossAxisAlignment.start,
                        //  children: [
                        //    Text("Likes: ${widget.model.likes}"),
                        //    Text("Downloads: ${widget.model.downloads}"),
                        //  ],
                        //),
                      ]
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}
