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
  static final Config _instance = Config._internal();
  Config._internal();

  factory Config () {
    return _instance;
  }

  final List<String> _externalModels = [];
  List<String> get externalModels => _externalModels;
  addExternalModel(String path) async {
    _externalModels.add(path);
    await _save('externalModels', _externalModels);
  }
  removeExternalModel(String path) async {
    _externalModels.remove(path);
    await _save('externalModels', _externalModels);
  }

  Hints hints = Hints();
  String _proxy = '';
  bool _proxyEnabled = false;
  ThemeMode _mode = ThemeMode.system;
  Envvars envvars = Envvars();

  String get proxy => _proxy;
  setProxy(String value) async {
    _proxy = value;
    await _save('proxy', value);
  }

  bool get proxyEnabled => _proxyEnabled;
  setProxyEnabled(bool value) async {
    _proxyEnabled = value;
    await _save('proxyEnabled', value);
  }

  ThemeMode get themeMode => _mode;
  setThemeMode(ThemeMode value) async {
    _mode = value;
    await _save('mode', value.index);
  }

  void reset() {
    hints = Hints();
    _proxy = '';
    _proxyEnabled = false;
    _mode = ThemeMode.system;
    envvars = Envvars();
  }

  Future<String> _getProxy() async {
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

  Future<void> loadFromFile() async {
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
      _externalModels.addAll(List<String>.from(json['externalModels'] ?? []));
    }
  }

  Future<void> _save(String key, dynamic value) async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/config.json');
    Map<String, dynamic> json = {};
    if (await file.exists()) {
      final contents = await file.readAsString();
      json = jsonDecode(contents);
    }
    json[key] = value;
    const encoder = JsonEncoder.withIndent("  ");
    await file.writeAsString(encoder.convert(json));
  }

}
