// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/import/huggingface.dart';
import 'package:inference/pages/import/providers/import_provider.dart';
import 'package:inference/pages/import/widgets/import_geti_model_dialog.dart';
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
            backgroundColor: theme.scaffoldBackgroundColor,
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
                header: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text("Import model",
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
                    body: const  Huggingface(),
                  ),
                  PaneItemAction(
                    icon: const Icon(FluentIcons.project_collection),
                    title: const Text("Local disk"),
                    onTap: () => showImportGetiModelDialog(context,
                      callback: (projects) {
                        if (projects != null && projects.isNotEmpty) {
                          if (projects.length == 1) {
                            GoRouter.of(context).go("/models/inference", extra: projects.first);
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
                            importProvider.selectedModel?.convertToProject().then((project) {
                              if (context.mounted){
                                GoRouter.of(context).push('/models/download', extra: project);
                              }
                            });
                          }
                        ),
                        child: const Text("Import selected model"),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape:WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side:  const BorderSide(color: Color(0XFF545454)),
                        )),
                      ),
                      child: const Text("Close"),
                      onPressed: () =>  GoRouter.of(context).go("/models"),
                    ),
                  ),
                ]
              ),
            ),
          )

        ],
      ),
    );
  }
}
