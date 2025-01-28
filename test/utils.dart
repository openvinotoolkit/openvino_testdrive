// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:math';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  late String applicationSupportPath;

  FakePathProviderPlatform({String? appDirSuffix}) {
    if (appDirSuffix != null) {
      applicationSupportPath = 'com.openvino.console.TestDir_$appDirSuffix';
    } else {
      final randomSuffix = (Random().nextInt(90000000) + 10000000).toString();
      applicationSupportPath = 'com.openvino.console.TestDir_$randomSuffix';
    }
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final fullPath = '${Directory.systemTemp.path}/$applicationSupportPath';
    final directory = Directory(fullPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    return fullPath;
  }

  deleteAppDir() async {
    final fullPath = '${Directory.systemTemp.path}/$applicationSupportPath';
    final directory = Directory(fullPath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}