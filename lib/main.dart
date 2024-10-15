import 'package:flutter/material.dart';
import 'package:inference/openvino_console_app.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

void main() async {
  MediaKit.ensureInitialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferenceProvider>(create: (_) => PreferenceProvider("AUTO")),
        ChangeNotifierProvider<ProjectProvider>(create: (_) => ProjectProvider([])),
      ],
      child: const OpenVINOTestDriveApp(),
    );
  }
}
