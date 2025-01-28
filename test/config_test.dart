// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/config.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'mocks.dart';
import 'utils.dart';

void main() {
  late MockEnvvars envvars;

  setUpAll(() {
    envvars = MockEnvvars();
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  setUp(() async {
    await deleteConfigFile();
  });

  test('Config proxy settings', () async {
    await Config.setProxy('http://proxy.example.com:8080');
    expect(Config.proxy, 'http://proxy.example.com:8080');

    await Config.setProxyEnabled(true);
    expect(Config.proxyEnabled, true);

    await Config.setProxyEnabled(false);
    expect(Config.proxyEnabled, false);
  });

  test('Config theme mode', () async {
    await Config.setThemeMode(ThemeMode.dark);
    expect(Config.themeMode, ThemeMode.dark);

    await Config.setThemeMode(ThemeMode.light);
    expect(Config.themeMode, ThemeMode.light);

    await Config.setThemeMode(ThemeMode.system);
    expect(Config.themeMode, ThemeMode.system);
  });

  test('Config load and save', () async {
    expect(Config.proxyEnabled, false);
    expect(Config.proxy, '');
    expect(Config.themeMode, ThemeMode.system);

    await Config.setProxy('http://proxy.example.com:8080');
    await Config.setProxyEnabled(true);
    await Config.setThemeMode(ThemeMode.dark);

    await Config.loadFromFile();
    expect(Config.proxy, 'http://proxy.example.com:8080');
    expect(Config.proxyEnabled, true);
    expect(Config.themeMode, ThemeMode.dark);
  });

  test('Load proxy from envvar', () async {
    const proxy = 'http://proxy.foo.bar:8080';
    when(() => envvars.proxy).thenReturn(proxy);
    Config.envvars = envvars;

    await Config.loadFromFile();
    expect(Config.proxy, '');

    await Config.setProxyEnabled(true);
    await Config.loadFromFile();
    expect(Config.proxy, proxy);
  });
}
