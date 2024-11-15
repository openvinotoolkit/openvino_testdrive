import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/import/import_page.dart';
import 'package:inference/inference/inference_page.dart';
import 'package:inference/interop/device.dart';
import 'package:inference/interop/image_inference.dart';
import 'package:inference/project.dart';
import 'package:inference/projects/projects_page.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/utils.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart';

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(child: ProjectsPage()),
      routes: <RouteBase>[
        GoRoute(
          path: 'inference',
          pageBuilder: (context, state) => NoTransitionPage(child: InferencePage(state.extra! as Project)),
        ),
        GoRoute(
          path: 'import',
          pageBuilder: (context, state) => const NoTransitionPage(child: ImportPage()),
        ),
      ],
    ),
  ],
);


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
    //NOTE: Do we need to add listeneres to windowManager here?
    super.initState();

    //setLoggingOutput();
    ensureFontIsStored().then((_) {
      fontPath().then((font) => ImageInference.setupFont(font));
    });

    setupErrors();

    Device.getDevices().then((devices) {
        devices.forEach((p) => print("${p.id}, ${p.name}"));
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
      title: const Text('Dark mode'),
      icon: Builder(builder: (context) {
        final appTheme = context.watch<AppTheme>();
        if (appTheme.mode == ThemeMode.dark) {
          return const Icon(FluentIcons.clear_night);
        } else if (appTheme.mode == ThemeMode.light) {
          return const Icon(FluentIcons.brightness);
        } else {
          return const Icon(FluentIcons.half_alpha);
        }
      }),
      body: const SizedBox.shrink(),
      onTap: () {
        final appTheme = context.read<AppTheme>();
        appTheme.toggleTheme();
      },
    ),
  ];

  int? _calculateSelectedIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    int? index = originalNavigationItems
      .indexWhere((item) {
        return uri.startsWith((item.key as ValueKey).value);
    });
    if (index == -1) {
      index = null;
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
        appBar: NavigationAppBar(
          leading: Container(),
          height: 48,
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
      );
  }
}
