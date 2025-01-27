// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async {
    const path = 'com.openvino.console.TestDir';
    final fullPath = '${Directory.systemTemp.path}/$path';
    final directory = Directory(fullPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    return fullPath;
  }
}

Future<void> deleteConfigFile() async {
  final directory = await getApplicationSupportDirectory();
  final file = File('${directory.path}/config.json');
  if (await file.exists()) {
    await file.delete();
  }
}