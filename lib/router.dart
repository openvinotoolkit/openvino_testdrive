
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/openvino_console_app.dart';
import 'package:inference/pages/home/home.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) =>  OpenVINOTestDriveApp(
      shellContext: _shellNavigatorKey.currentContext,
      child: child,
    ),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/models', builder: (context, state) => Container(color: Colors.blue, child: const Text('Models'),)),
    ],
  )
]);
