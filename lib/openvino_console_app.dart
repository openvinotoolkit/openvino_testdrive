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
import 'package:inference/theme.dart';
import 'package:inference/utils.dart';
import 'package:provider/provider.dart';

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
  const OpenVINOTestDriveApp({super.key});

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
        devices.forEach((p) => print("${p.id}, ${p.name}"));
      PreferenceProvider.availableDevices = devices;
    });

    final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
    final addProjects = projectsProvider.addProjects;
    loadProjectsFromStorage().then(addProjects);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: intelTheme,
      routerConfig: _router,
    );
  }
}
