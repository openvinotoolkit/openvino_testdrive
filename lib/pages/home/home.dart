// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/home/widgets/featured_card.dart';
import 'package:inference/pages/models/widgets/model_card.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/project.dart';
import 'package:inference/widgets/empty_model_widget.dart';
import 'package:inference/widgets/fixed_grid.dart';
import 'package:inference/widgets/import_model_button.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Model>> popularModelsFuture;
  bool orderAscend = false;
  Map<String, Project> projectModelMap = {}; // Map to hold modelId and a corresponding project

  @override
  void initState() {
    super.initState();
    final importer = ManifestImporter('assets/manifest.json');
    popularModelsFuture = importer.loadManifest().then((_) => importer.getPopularModels());
  }

  void updateProjectModelMap(List<Project> projects) {
    // Store model.id -> project. If duplicate projects with a model exists, only one is kept in this map
    projectModelMap = {
      for (var project in projects) project.modelId: project
    };
  }

  Project? getProjectWithModel(Model model) {
    // Retrieve a project given the modelId
    return projectModelMap[model.id] ?? projectModelMap["OpenVINO/${model.id}"];
  }

  bool projectExistsWithModel(Model model){
    return getProjectWithModel(model) != null;
  }

  void downloadFeaturedModel(Model model){
    model.convertToProject().then((project) {
      if (mounted) {
        GoRouter.of(context).push('/models/download', extra: project);
      }
    });

  }
  void openFeaturedModel(Model model){
    var project = getProjectWithModel(model);
    if (project != null){
      GoRouter.of(context).push("/models/inference", extra: project);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      padding: const EdgeInsets.all(0),
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Image.asset("images/banner.png", fit: BoxFit.cover, width: double.infinity, height: 400,),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset("images/openvino_logo.svg", width: 81),
                              const Text("TestDrive",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Model>>(
              future: popularModelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ProgressRing();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No popular models available');
                } else {
                  final popularModels = snapshot.data!;
                  return Consumer<ProjectProvider>(
                      builder: (context, projectProvider, child) {
                        // Update the map whenever the projects are updated
                        updateProjectModelMap(projectProvider.projects);
                        return HorizontalScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 4),
                            child: Row(
                              children: popularModels.map((model) =>
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: popularModels.indexOf(model) ==
                                          popularModels.length - 1 ? 0 : 32,
                                    ),
                                    child: FeaturedCard(
                                        model: model,
                                        onDownload: downloadFeaturedModel,
                                        onOpen: openFeaturedModel,
                                        downloaded: projectExistsWithModel(
                                            model)
                                    ),
                                  )).toList(),
                            ),
                          ),
                        );
                      });
                }
              },
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, top: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1228),
              child: Consumer<ProjectProvider>(builder: (context, value, child) {
                final projects = value.projects.toList();
                projects.sort((a,b) => a.name.compareTo(b.name) * (orderAscend ? -1 : 1));

                return FixedGrid(
                  tileWidth: 268,
                  centered: true,
                  spacing: 36,
                  itemCount: projects.length,
                  header: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My models',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(icon: const Icon(FluentIcons.sort_down), onPressed: () {
                                setState(() {
                                    orderAscend = !orderAscend;
                                });
                            }),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 24),
                              child: const Divider(direction: Axis.vertical,style: DividerThemeData(
                                verticalMargin: EdgeInsets.symmetric(horizontal: 8),
                              ),),
                            ),
                            const ImportModelButton(),
                          ],
                        )
                      ],
                    ),
                  ),
                  emptyWidget: const EmptyModelListWidget(),
                  itemBuilder: (context, index) {
                    return ModelCard(project: projects.elementAt(index));
                  }
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
