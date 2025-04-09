// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/import/huggingface.dart';
import 'package:inference/pages/import/providers/import_provider.dart';
import 'package:inference/pages/import/widgets/import_model_dialog.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/project_filter_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/widgets/controls/close_model_button.dart';
import 'package:provider/provider.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final updatedTheme = theme.copyWith(
        navigationPaneTheme: theme.navigationPaneTheme.merge(NavigationPaneThemeData(
            backgroundColor: backgroundColor.of(theme),
        ))
    );

    return ChangeNotifierProvider<ImportProvider>(
      create: (_) => ImportProvider(),
      child: Stack(
        children: [
          FluentTheme(
            data: updatedTheme,
            child: NavigationView(
              pane: NavigationPane(
                size: const NavigationPaneSize(topHeight: 64),
                header: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Import model",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                selected: selected,
                onChanged: (i) => setState(() {selected = i;}),
                displayMode: PaneDisplayMode.top,
                items: [
                  PaneItem(
                    icon: SvgPicture.asset('images/huggingface_logo-noborder.svg', width: 15,),
                    title: const Text("Huggingface"),
                    body: ChangeNotifierProvider<ProjectFilterProvider>(
                      create: (_) => ProjectFilterProvider(),
                      child: const  Huggingface()
                    ),
                  ),
                  PaneItemAction(
                    icon: const Icon(FluentIcons.project_collection),
                    title: const Text("Local disk"),
                    onTap: () => showImportModelDialog(context,
                      callback: (projects) {
                        if (projects != null && projects.isNotEmpty) {
                          if (projects.length == 1) {
                            GoRouter.of(context).pushReplacement("/models/inference", extra: projects.first);
                          } else {
                            GoRouter.of(context).pop();
                          }
                        }
                      }
                    ),
                  ),
                ],
              )
            ),
          ),
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Consumer<ImportProvider>(builder: (context, importProvider, child) {
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: FilledButton(
                        onPressed: (importProvider.selectedModel == null
                          ? null
                          : () {
                            if (importProvider.selectedModel != null) {
                              PublicProject.fromModelManifest(importProvider.selectedModel!).then((project) {
                                if (context.mounted){
                                  GoRouter.of(context).push('/models/download', extra: project);
                                }
                              });
                            }
                          }
                        ),
                        child: const Text("Import selected model"),
                      ),
                    );
                  }),
                  const CloseModelButton(),
                ]
              ),
            ),
          )

        ],
      ),
    );
  }
}
