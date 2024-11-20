import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inference/config.dart';
import 'package:inference/interop/device.dart';
import 'package:inference/openvino_console_app.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:provider/provider.dart';
import 'package:args/args.dart';

void testConnection() async {
  final dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 10)));
  
  try {
    await dio.get(collections[0].path);
  } on DioException catch(ex) {
    if (ex.type == DioExceptionType.connectionError) {
      // Perhaps proxy issue, disable proxy in future requests.
      Config.proxyDirect = true;
    }
  }
}

void main(List<String> arguments) async {
  final parser = ArgParser()..addFlag('test-bindings', defaultsTo: false);

  ArgResults argResults = parser.parse(arguments);
  if (argResults.flag('test-bindings')) {
    await testBindings();
  } else {
    testConnection();
    runApp(const App());
  }
}

Future<void> testBindings() async {
  print("Testing bindings...");
  try {
    final devices = await Device.getDevices();
    for (var device in devices) {
      print("${device.id}, ${device.name}");
    }
    print("Bindings ok");
    exit(0); // Exit with success
  } catch (e) {
    print("Error: $e");
    print("Exit with failure");
    exit(1); // Exit with failure
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferenceProvider>(create: (_) => PreferenceProvider(PreferenceProvider.defaultDevice)),
        ChangeNotifierProvider<ProjectProvider>(create: (_) => ProjectProvider([])),
      ],
      child: const OpenVINOTestDriveApp(),
    );
  }
}
