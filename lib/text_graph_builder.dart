// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:inference/project.dart';
import 'package:path/path.dart';

class TextGraphBuilder {
  final Project project;
  final Context platformContext;
  TextGraphBuilder(this.project): platformContext = Context(style: Style.platform);

  String modelPath(String path) {
    return platformContext.join(project.storagePath, path).replaceAll("\\", "/");
  }

  buildGraph() {
    //Assume one task for now.
    final task = project.tasks[0];
    return """
input_stream: "input"
output_stream: "output"

node {
    calculator : "LLMCalculator"
    input_stream : "PROMPT:input"
    output_stream: "TOKEN:output"
    node_options: {
        [type.googleapis.com/mediapipe.LLMCalculatorOptions] {
            tokenizer_model_path: "${modelPath(task.modelPaths[0])}"
            detokenizer_model_path: "${modelPath(task.modelPaths[1])}"
            model_path: "${modelPath(task.modelPaths[2])}"
        }
    }

}
    """;
  }

}
