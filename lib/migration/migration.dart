// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:inference/importers/model_manifest.dart';

class Migration {
  final String from;
  final String to;

  Map<String, dynamic> migrate(Map<String, dynamic> input, List<ModelManifest> manifest) {
    return input;
  }
  const Migration({required this.from, required this.to});
}
