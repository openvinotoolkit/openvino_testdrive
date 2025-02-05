// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/batch_inference.dart';
import 'package:inference/pages/computer_vision/live_inference.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/utils.dart';
import 'package:inference/widgets/controls/close_model_button.dart';
import 'package:provider/provider.dart';

class ComputerVisionPage extends StatefulWidget {
  final Project project;
  const ComputerVisionPage(this.project, {super.key});

  @override
  State<ComputerVisionPage> createState() => _ComputerVisionPageState();
}

class _ComputerVisionPageState extends State<ComputerVisionPage> {

  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final updatedTheme = theme.copyWith(
        navigationPaneTheme: theme.navigationPaneTheme.merge(NavigationPaneThemeData(
            backgroundColor: theme.scaffoldBackgroundColor,
        ))
    );

    return ChangeNotifierProxyProvider<PreferenceProvider, ImageInferenceProvider>(
      create: (_) {
        final device = Provider.of<PreferenceProvider>(context, listen: false).device;
        return ImageInferenceProvider(widget.project, device)..init();
      },
      update: (_, preferences, imageInferenceProvider) {
        if (imageInferenceProvider != null && imageInferenceProvider.sameProps(widget.project, preferences.device)) {
          return imageInferenceProvider;
        }
        final provider = ImageInferenceProvider(widget.project, preferences.device);
        // If there was a previous provider make sure we close the camera before loading a new one.
        // This ensures that the camera is ready to be used again when the model is loaded.
        if (imageInferenceProvider != null) {
          imageInferenceProvider.closeCamera().then((_) {
              provider.init();
          });
        } else {
          provider.init();
        }
        return provider;
      },
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
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: widget.project.thumbnailImage(),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(widget.project.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                //customPane: CustomNavigationPane(),
                selected: selected,
                onChanged: (i) => setState(() {selected = i;}),
                displayMode: PaneDisplayMode.top,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.processing),
                    title: const Text("Live Inference"),
                    body: LiveInference(project: widget.project),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.project_collection),
                    title: const Text("Batch Inference"),
                    body: const BatchInference(),
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
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: FilledButton(
                      child: const Text("Export model"),
                      onPressed: () => downloadProject(widget.project),
                    ),
                  ),
                  //Padding(
                  // padding: const EdgeInsets.all(4),
                  // child: OutlinedButton(
                  //   child: const Text("Fine-tune"),
                  //    onPressed: () => print("close")
                  //  ),
                  //),
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
