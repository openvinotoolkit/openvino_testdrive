// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0
import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/interop/device.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/utils.dart';
import 'package:inference/widgets/feedback_button.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';


class OpenVINOTestDriveApp extends StatefulWidget {
  const OpenVINOTestDriveApp({
    super.key,
    required this.child,
    required this.shellContext,
  });


  final Widget child;
  final BuildContext? shellContext;

  @override
  State<OpenVINOTestDriveApp> createState() => _OpenVINOTestDriveAppState();
}

class _OpenVINOTestDriveAppState extends State<OpenVINOTestDriveApp> {
  @override
  void initState() {
    super.initState();

    //setLoggingOutput();
    ensureFontIsStored().then((_) {
      fontPath().then((font) => ImageInference.setupFont(font));
    });

    setupErrors();

    Device.getDevices().then((devices) {
      PreferenceProvider.availableDevices = devices;
    });

    final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
    final addProjects = projectsProvider.addProjects;
    loadProjectsFromStorage().then(addProjects);
  }

  late final List<NavigationPaneItem> originalNavigationItems = [
    PaneItem(
      key: const ValueKey('/home'),
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: const SizedBox.shrink()
    ),
    PaneItem(
      key: const ValueKey('/models'),
      icon: const Icon(FluentIcons.iot),
      title: const Text('Models'),
      body: const SizedBox.shrink()
    ),
    PaneItem(
      key: const ValueKey('/workflows'),
      icon: const Icon(FluentIcons.flow),
      title: const Text('Workflows'),
      body: const SizedBox.shrink(),
      enabled: false,
    ),
    PaneItem(
      key: const ValueKey('/rag'),
      icon: const Icon(FluentIcons.library),
      title: const Text('Knowledge base'),
      body: const SizedBox.shrink(),
      enabled: false
    )
  ].map<NavigationPaneItem>((item) => PaneItem(
    key: item.key,
    icon: item.icon,
    title: item.title,
    body: item.body,
    enabled: item.enabled,
    onTap: () {
      final path = (item.key as ValueKey).value;
      if (GoRouterState.of(context).uri.toString() != path) {
        GoRouter.of(context).go(path);
      }
      item.onTap?.call();
    },
  )).toList();

  late final List<NavigationPaneItem> footerNavigationItems = [
    PaneItem(
      key: const ValueKey('/settings'),
      title: const Text('Settings'),
      icon: const Icon(FluentIcons.settings),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/settings') {
          GoRouter.of(context).go('/settings');
        }
      },
    ),
  ];

  int? _calculateSelectedIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    int? indexOriginal = originalNavigationItems
      .indexWhere((item) {
        return uri.startsWith((item.key as ValueKey).value);
    });
    if (indexOriginal == -1) {
      int indexFooter = footerNavigationItems
        .indexWhere((element) => element.key == Key(uri));
      if (indexFooter == -1) {
        return 0;
      }
      return originalNavigationItems.length + indexFooter;
    }
    return indexOriginal;
  }

  void toggleMaximize() {
   windowManager.isMaximized().then((isMaximized) {
      if (isMaximized) {
        windowManager.unmaximize();
      } else {
        windowManager.maximize();
      }
   });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NavigationView(
          appBar: NavigationAppBar(
            leading: Container(),
            height: 48,
            actions: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => windowManager.startDragging(),
                    onDoubleTap: toggleMaximize,
                    child: SizedBox(
                      height: 48,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: Platform.isMacOS ? 60 : 5),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: Image.asset('images/logo_50.png', width: 20, height: 20)
                                ),
                              ),
                              const Text("OpenVINO™ Test Drive"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                (Platform.isMacOS ? Container() : const WindowButtons()),
              ]
            )
          ),
          paneBodyBuilder: (item, child) {
            final name =
                item?.key is ValueKey ? (item!.key as ValueKey).value : null;
            return FocusTraversalGroup(
              key: ValueKey('body$name'),
              child: widget.child,
            );
          },
          pane: NavigationPane(
            selected: _calculateSelectedIndex(context),
            toggleable: false,
            displayMode: PaneDisplayMode.compact,
            items: originalNavigationItems,
            footerItems: footerNavigationItems,
          ),
        ),
        const Positioned(
          right: 24,
          bottom: 24,
          child: FeedbackButton()
        )
      ],
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
