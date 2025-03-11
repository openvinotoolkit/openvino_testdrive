// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:inference/config.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/project.dart';
import 'package:inference/router.dart';
import 'package:inference/widgets/dialogs/critical_error.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Dio dioClient() {
  final dio = Dio();
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.findProxy = (uri) {
        if (Config().proxyEnabled) {
          final proxyUri = Uri.parse(Config().proxy);
          final proxyHost = proxyUri.host.isNotEmpty ? proxyUri.host : Config().proxy;
          final proxyPort = proxyUri.port != 0 ? ':${proxyUri.port}' : '';
          return "PROXY $proxyHost$proxyPort";
        } else {
          return "DIRECT";
        }
      };
      return client;
    }
  );
  return dio;
}

String parseWpad(String wpad) {
  final regex = RegExp(r'return\s+"PROXY ([^"]+)";');
  final matches = regex.allMatches(wpad);
  if (matches.isNotEmpty) {
    return matches.last.group(1) ?? '';
  }
  return '';
}


Future<T?> showGlobalDialog<T extends Object?>(WidgetBuilder builder) async {
  if (rootNavigatorKey.currentContext?.mounted == true) {
    return await showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: builder
    );
  } else {
    return null;
  }
}

void setupErrors() async {
    final directory = await getApplicationSupportDirectory();
    final platformContext = Context(style: Style.platform);

    final errorPath = platformContext.join(directory.path, "errors.log");

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      final contents = """
${details.exception.toString()}
${details.stack.toString()}

""";
    File(errorPath).writeAsStringSync(contents, mode: FileMode.append);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      print("PlatformDispatcher error ");

      final contents = """
${error.toString()}
${stack.toString()}

""";
      print(contents);
      File(errorPath).writeAsStringSync(contents, mode: FileMode.append);
      showCriticalErrorDialog(error, stack);
      return true;
    };
}

Future<void> downloadProject(Project project) async {
  final file = await FilePicker.platform.saveFile(
    dialogTitle: "Please select an output location:",
  );
  if (file != null) {
    await copyProjectData(project, file);
  }
}

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).floor();
    return "${NumberFormat("#,##0").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class Envvars {
  String get proxy {
    final proxyEnv = Platform.environment['https_proxy'] ?? Platform.environment['HTTPS_PROXY'] ?? Platform.environment['http_proxy'] ?? Platform.environment['HTTP_PROXY'];
    if (proxyEnv != null) {
      return proxyEnv;
    }
    return '';
  }
}
