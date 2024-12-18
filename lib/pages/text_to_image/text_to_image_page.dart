// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/text_to_image/live_inference_pane.dart';
import 'package:inference/pages/text_to_image/providers/text_to_image_inference_provider.dart';
import 'package:inference/pages/text_to_image/performance_metrics_pane.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/utils.dart';
import 'package:inference/widgets/controls/close_model_button.dart';
import 'package:provider/provider.dart';

class TextToImagePage extends StatefulWidget {
  final Project project;
  const TextToImagePage(this.project, {super.key});

  @override
  State<TextToImagePage> createState() => _TextToImagePageState();
}

class _TextToImagePageState extends State<TextToImagePage> {


  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final updatedTheme = theme.copyWith(
        navigationPaneTheme: theme.navigationPaneTheme.merge(NavigationPaneThemeData(
            backgroundColor: theme.scaffoldBackgroundColor,
        ))
    );
    final textColor = theme.typography.body?.color ?? Colors.black;

    const inferencePane = TTILiveInferencePane();
    const metricsPane = TTIPerformanceMetricsPane();
    return ChangeNotifierProxyProvider<PreferenceProvider, TextToImageInferenceProvider>(
      lazy: false,
      create: (_) {
        final device = Provider.of<PreferenceProvider>(context, listen: false).device;
        return TextToImageInferenceProvider(widget.project, device)..init();
      },
      update: (_, preferences, imageInferenceProvider) {
        if (imageInferenceProvider != null && imageInferenceProvider.sameProps(widget.project, preferences.device)) {
          return imageInferenceProvider;
        }
        return TextToImageInferenceProvider(widget.project, preferences.device)..init();
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
                    icon: SvgPicture.asset("images/playground.svg",
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                      width: 15,
                    ),
                    title: const Text("Live Inference"),
                    body: inferencePane,
                  ),
                  PaneItem(
                    icon: SvgPicture.asset("images/stats.svg",
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                      width: 15,
                    ),
                    title: const Text("Performance metrics"),
                    body: metricsPane,
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
