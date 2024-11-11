import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inference/config.dart';
import 'package:inference/openvino_console_app.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:provider/provider.dart';

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

void main() {
  testConnection();
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
      ],
      child: const OpenVINOTestDriveApp(),
    );
  }
}
