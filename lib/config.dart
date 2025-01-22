// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/utils.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum HintsEnum { intelCoreLLMPerformanceSuggestion }

class Hints {
  late Map<HintsEnum, bool> hints;
  Hints() {
    hints = { for (var v in HintsEnum.values) v : true };
  }
}

class Config {
  static Hints hints = Hints();
  static String _proxy = '';
  static bool _proxyEnabled = false;
  static ThemeMode _mode = ThemeMode.system;

  static String get proxy => _proxy;
  static set proxy(String value) {
    _proxy = value;
    _save('proxy', value);
  }

  static bool get proxyEnabled => _proxyEnabled;
  static set proxyEnabled(bool value) {
    _proxyEnabled = value;
    _save('proxyEnabled', value);
  }

  static ThemeMode get themeMode => _mode;
  static set themeMode(ThemeMode value) {
    _mode = value;
    _save('mode', value.index);
  }

  static Future<void> loadFromFile() async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/config.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      _proxyEnabled = json['proxyEnabled'] ?? false;
      if (json['proxy'] is String && json['proxy'].isNotEmpty) {
        _proxy = json['proxy'];
      } else if (_proxyEnabled) {
        _proxy = await getProxy();
      }
      _mode = ThemeMode.values[json['mode'] ?? 0];
    }
  }

  static Future<void> _save(String key, dynamic value) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/config.json');
    Map<String, dynamic> json = {};
    if (await file.exists()) {
      final contents = await file.readAsString();
      json = jsonDecode(contents);
    }
    json[key] = value;
    await file.writeAsString(jsonEncode(json));
  }
}