
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/openvino_console_app.dart';
import 'package:inference/pages/download_model/download_model.dart';
import 'package:inference/pages/home/home.dart';
import 'package:inference/pages/import/import.dart';
import 'package:inference/pages/models/models.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:provider/provider.dart';

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
        GoRoute(path: '/models/download', builder: (context, state) => ChangeNotifierProvider<DownloadProvider>(create: (_) =>
          DownloadProvider(state.extra as PublicProject), child: DownloadModelPage(project: state.extra as PublicProject)),
        ),
      ],
    )
  ]
);
