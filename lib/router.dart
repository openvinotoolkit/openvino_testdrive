
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/importers/manifest_importer.dart';
import 'package:inference/openvino_console_app.dart';
import 'package:inference/pages/home/home.dart';
import 'package:inference/pages/import/import.dart';
import 'package:inference/pages/knowledge_base/knowledge_base.dart';
import 'package:inference/pages/models/models.dart';
import 'package:inference/pages/models/inference.dart';
import 'package:inference/project.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) =>  OpenVINOTestDriveApp(
        shellContext: _shellNavigatorKey.currentContext,
        child: child,
      ),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/models', builder: (context, state) => const ModelsPage()),
        GoRoute(path: '/models/import', builder: (context, state) => const ImportPage()),
        GoRoute(path: '/models/download', builder: (context, state) => Container(color: Colors.blue, child: Text('Downloading model: ${(state.extra as Model).id}'))),
        GoRoute(path: '/models/inference', builder: (context, state) => InferencePage(state.extra as Project)),
        GoRoute(path: '/knowledge_base', builder: (context, state) => const KnowledgeBasePage()),
      ],
    )
  ]
);
