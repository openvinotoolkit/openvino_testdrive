// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/config.dart';
//import 'package:inference/langchain/object_box/object_box.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:inference/router.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const String title = 'OpenVINO TestDrive';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  //await ObjectBox.create();
  await Config.loadFromFile();
  WindowOptions windowOptions = WindowOptions(
    size: const Size(1400, 1024),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: Platform.isMacOS,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferenceProvider>(create: (_) => PreferenceProvider(PreferenceProvider.defaultDevice)),
        ChangeNotifierProvider<ProjectProvider>(create: (_) => ProjectProvider([])),
        ChangeNotifierProvider<DownloadProvider>(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => AppTheme()),
      ],
      builder: (context, child) {
        final theme = context.watch<AppTheme>();
        return FluentApp.router(
          title: title,
          themeMode: theme.mode,
          debugShowCheckedModeBanner: false,
          color: theme.color,
          theme: FluentThemeData(
            accentColor: theme.color,
            scaffoldBackgroundColor: const Color(0x80FFFFFF),
            visualDensity: VisualDensity.standard,
            fontFamily: theme.fontFamily,
          ),
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF2C2C2C),
            accentColor: theme.darkColor,
            cardColor: const Color(0xFF383838),
            visualDensity: VisualDensity.standard,
            fontFamily: theme.fontFamily,
          ),
          // locale: theme.locale,
          builder: (context, child) => NavigationPaneTheme(
            data: const NavigationPaneThemeData(
              // backgroundColor: theme.windowEffect != flutter_acrylic.WindowEffect.disabled
              //   ? Colors.transparent : null,
            ),
            child: child!,
          ),
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}
