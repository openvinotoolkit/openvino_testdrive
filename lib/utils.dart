// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:inference/config.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/project.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Dio dioClient() {
  final dio = Dio();
  if (Config.proxyDirect) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return 'DIRECT';
        };
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      }
    );
  }
  return dio;
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
