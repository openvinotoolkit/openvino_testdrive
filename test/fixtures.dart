// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/project.dart';

Project largeLanguageModel() {
  return PublicProject(
    "test_id", "llm-model", "1.0.0", "TinyLlama", "2024-04-25T19:16:51.714000+00:00", ProjectType.text, "/dev/null", Image.asset("images/model_thumbnails/llama.jpg"), null
  )
  ..tasks.add(Task("task_id", "LLM", "LLM", [], null, [], "LLamaForCasualLM","int8"));
}
