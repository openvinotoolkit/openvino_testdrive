// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:inference/utils.dart';

void main() {
  group('parseWpad', () {
    test('should return proxy address when valid WPAD script is provided', () {
      const wpad = '''
function FindProxyForURL(url, host) {
  return "PROXY proxy.example.com:8080";
}''';
      final result = parseWpad(wpad);
      expect(result, 'proxy.example.com:8080');
    });

    test('should return empty string when WPAD script does not contain proxy address', () {
      const wpad = '''
function FindProxyForURL(url, host) {
  return "DIRECT";
}''';
      final result = parseWpad(wpad);
      expect(result, '');
    });

    test('should return last proxy address when multiple proxy addresses are provided', () {
      const wpad = '''
function FindProxyForURL(url, host) {
  if (url.includes("example1.com")) {
    return "PROXY proxy1.example.com:8080";
  }
  return "PROXY proxy2.example.com:8080";
}''';
      final result = parseWpad(wpad);
      expect(result, 'proxy2.example.com:8080');
    });

    test('should return empty string when WPAD script is empty', () {
      const wpad = '';
      final result = parseWpad(wpad);
      expect(result, '');
    });

    test('should return empty string when WPAD script is null', () {
      const String? wpad = null;
      final result = parseWpad(wpad ?? '');
      expect(result, '');
    });
  });
}

