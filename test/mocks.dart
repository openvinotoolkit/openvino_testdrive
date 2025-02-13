// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:inference/interop/llm_inference.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/utils.dart';
import 'package:mocktail/mocktail.dart';

class MockEnvvars extends Mock implements Envvars {}

class LLMInferenceInstance extends Mock implements LLMInference {}

class MockLLMInference {
  late LLMInferenceInstance instance;
  final listenerCallback = Completer<void>();
  final promptCallback = Completer<void>();
  final complete = Completer<void>();

  List<dynamic> callocs = [];

  MockLLMInference({
      String tokenizeConfig = "{}",
      String listenerAnswer = "",
      //String promptAnswer = "",
  }) {
    instance = LLMInferenceInstance();
    when(() => instance.getTokenizerConfig()).thenReturn(tokenizeConfig);
    when(() => instance.setListener(any())).thenAnswer((func) async {
      await listenerCallback.future;
      func.positionalArguments[0](listenerAnswer);
    });
    final metrics = calloc<Metrics>();
    callocs.add(metrics);
    when(() => instance.prompt(any(), false, any(), any())).thenAnswer((_) async {
      await promptCallback.future;
      complete.complete();
      return ModelResponse("", metrics.ref);
    });
  }

  void clean() {
    for (final alloc in callocs) {
      calloc.free(alloc);
    }
  }
}
