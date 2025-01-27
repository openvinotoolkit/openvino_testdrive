// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
  static Envvars envvars = Envvars();

  static String get proxy => _proxy;
  static setProxy(String value) async {
    _proxy = value;
    await _save('proxy', value);
  }

  static bool get proxyEnabled => _proxyEnabled;
  static setProxyEnabled(bool value) async {
    _proxyEnabled = value;
    await _save('proxyEnabled', value);
  }

  static ThemeMode get themeMode => _mode;
  static setThemeMode(ThemeMode value) async {
    _mode = value;
    await _save('mode', value.index);
  }

  static Future<String> _getProxy() async {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          return "DIRECT";
        };
        return client;
      },
    );
    try {
      final response = await dio.get('http://wpad/wpad.dat');
      if (response.statusCode == 200) {
        return parseWpad(response.data);
      }
    } catch (e) {
      print(e.toString());
    }

    final proxyEnv = envvars.proxy;
    if (proxyEnv.isNotEmpty) {
      return proxyEnv;
    }
    return '';
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
        _proxy = await _getProxy();
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
