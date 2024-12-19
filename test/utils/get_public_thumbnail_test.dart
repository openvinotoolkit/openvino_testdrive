// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/utils/get_public_thumbnail.dart';

void main() {

  group('getThumbnail', () {

      final testCases = [
        ["TinyLlama-1.1B-Chat-v1.0-fp16-ov", "images/model_thumbnails/llama.jpg"],
        ["Phi-3-mini-4k-instruct-fp16-ov", "images/model_thumbnails/microsoft.png"],
        ["mistral-7b-instruct-v0.1-int8-ov", "images/model_thumbnails/mistral.png"],
        ["RedPajama-INCITE-Chat-3B-v1-int8-ov", "images/model_thumbnails/redpajama.png"],
        ["codegen25-7b-multi-int4-ov", "images/model_thumbnails/codegen.png"],
        ["gpt-neox-20b-int8-ov", "images/model_thumbnails/eleuthera.jpg"],
        ["pythia-1.4b-int4-ov", "images/model_thumbnails/eleuthera.jpg"],
        ["starcoder2-15b-int8-ov", "images/model_thumbnails/starcoder2.png"],
        ["zephyr-7b-beta-int8-ov", "images/model_thumbnails/zephyr7b.png"],
        ["persimmon-8b-chat-int4-ov", "images/model_thumbnails/adeptai.png"],
        ["notus-7b-v1-fp16-ov", "images/model_thumbnails/notus.png"],
        ["dolly-v2-3b-int4-ov", "images/model_thumbnails/dolly.png"],
        ["unknown", "images/model_thumbnails/generic.jpg"],
        ["", "images/model_thumbnails/generic.jpg"],
      ];

      for (final testCase in testCases) {
        final input = testCase[0];
        final expectedAsset = testCase[1];
        test('test $input model', () {
          final subject = getThumbnail(input).image as AssetImage;
          expect(subject.assetName, expectedAsset);
        });
      }
  });
}
