// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:collection/collection.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/project.dart';
import 'package:path/path.dart';

class ImageGraphBuilder {
  final GetiProject project;
  final Context platformContext;
  final String device;
  ImageGraphBuilder(this.project, this.device): platformContext = Context(style: Style.platform);


  bool get isTaskChain => project.tasks.length > 1;

  Future<String> buildGraph() async {
    return """
      input_stream : "input"
      input_stream : "serialization_output"
      output_stream : "output"

      ${buildInferenceAdapterCalculators()}

      ${isTaskChain ? buildTaskChain() : buildSingleTask()}

      ${await buildOverlayCalculator()}

      ${buildSerializationCalculator()}
    """;
  }

  String buildSingleTask() {
    final Label? emptyLabel = project.tasks[0].labels.firstWhereOrNull((label) => label.isEmpty);
    if (emptyLabel == null) {
      return """
          ${buildInferenceCalculator(0, project.tasks[0])}
      """;
    } else {
      return """
          ${buildInferenceCalculator(0, project.tasks[0], "input", "inference_calculator_result")}
          node {
            calculator: "EmptyLabelCalculator"
            input_stream: "PREDICTION:inference_calculator_result"
            output_stream: "PREDICTION:inference_result"
            node_options: {
              [type.googleapis.com/mediapipe.EmptyLabelOptions] {
                id: "${emptyLabel.id}"
                label: "${emptyLabel.name}"
              }
            }
          }
      """;
    }
  }

  String buildTaskChain() {
    return """
        ${buildInferenceCalculator(0, project.tasks[0], "input", "detections")}
        node {
            calculator: "DetectionExtractionCalculator"
            input_stream: "INFERENCE_RESULT:detections"
            output_stream: "RECTANGLE_PREDICTION:detected_objects"
        }
        node {
            calculator: "CropCalculator"
            input_stream: "IMAGE:gated_input_image"
            input_stream: "DETECTION:input_detection_element"
            output_stream: "IMAGE:cropped_image"
        }

        ${project.tasks[1].taskType == "classification" ? buildDetectionClassification() : buildDetectionSegmentation()}
    """;
  }

  String buildDetectionClassification() {
    return """
        ${buildInferenceCalculator(1, project.tasks[1], "cropped_image", "classificationresult")}
        node {
          calculator: "EmptyLabelCalculator"
          input_stream: "PREDICTION:classificationresult"
          output_stream: "PREDICTION:classification"
          node_options: {
            [type.googleapis.com/mediapipe.EmptyLabelOptions] {
              id: "EMPTY_LABEL_ID_1"
              label: "EMPTY_LABEL_NAME_1"
            }
          }
        }
        node {
            calculator: "DetectionClassificationCombinerCalculator"
            input_stream: "DETECTION:input_detection_element"
            input_stream: "INFERENCE_RESULT:classification"
            output_stream: "DETECTION_CLASSIFICATIONS:output_of_loop_body"
        }
        node {
            calculator: "BeginLoopRectanglePredictionCalculator"
            input_stream: "ITERABLE:detected_objects"
            input_stream: "CLONE:input"
            output_stream: "ITEM:input_detection_element"
            output_stream: "CLONE:gated_input_image"
            output_stream: "BATCH_END:ext_ts"
        }
        node {
            calculator: "EndLoopRectanglePredictionsCalculator"
            input_stream: "ITEM:output_of_loop_body"
            input_stream: "BATCH_END:ext_ts"
            output_stream: "ITERABLE:output_classifications"
        }
        node {
          calculator: "EmptyLabelCalculator"
          input_stream: "PREDICTION:detections"
          output_stream: "PREDICTION:detectionswithempty"
          node_options: {
            [type.googleapis.com/mediapipe.EmptyLabelOptions] {
              id: "EMPTY_LABEL_ID_0"
              label: "EMPTY_LABEL_NAME_0"
            }
          }
        }
        node {
            calculator: "DetectionClassificationResultCalculator"
            input_stream: "DETECTION:detectionswithempty"
            input_stream: "DETECTION_CLASSIFICATIONS:output_classifications"
            output_stream: "DETECTION_CLASSIFICATION_RESULT:inference_result"
        }
      """;
  }

  String buildDetectionSegmentation() {
    return """
      ${buildInferenceCalculator(1, project.tasks[1], "cropped_image", "segmentationresult")}
      node {
        calculator: "EmptyLabelCalculator"
        input_stream: "PREDICTION:segmentationresult"
        output_stream: "PREDICTION:segmentation"
        node_options: {
          [type.googleapis.com/mediapipe.EmptyLabelOptions] {
            id: "EMPTY_LABEL_ID_1"
            label: "EMPTY_LABEL_NAME_1"
          }
        }
      }
      node {
          calculator: "DetectionSegmentationCombinerCalculator"
          input_stream: "DETECTION:input_detection_element"
          input_stream: "SEGMENTATION:segmentation"
          output_stream: "DETECTION_SEGMENTATIONS:output_of_loop_body"
      }

      node {
          calculator: "BeginLoopRectanglePredictionCalculator"
          input_stream: "ITERABLE:detected_objects"
          input_stream: "CLONE:input"
          output_stream: "ITEM:input_detection_element"
          output_stream: "CLONE:gated_input_image"
          output_stream: "BATCH_END:ext_ts"
      }
      node {
          calculator: "EndLoopPolygonPredictionsCalculator"
          input_stream: "ITEM:output_of_loop_body"
          input_stream: "BATCH_END:ext_ts"
          output_stream: "ITERABLE:output_segmentations"
      }
      node {
        calculator: "EmptyLabelCalculator"
        input_stream: "PREDICTION:detections"
        output_stream: "PREDICTION:detectionswithempty"
        node_options: {
          [type.googleapis.com/mediapipe.EmptyLabelOptions] {
            id: "EMPTY_LABEL_ID_0"
            label: "EMPTY_LABEL_NAME_0"
          }
        }
      }
      node {
          calculator: "DetectionSegmentationResultCalculator"
          input_stream: "DETECTION:detectionswithempty"
          input_stream: "DETECTION_SEGMENTATIONS:output_segmentations"
          output_stream: "DETECTION_SEGMENTATION_RESULT:inference_result"
      }
      """;
  }


  String buildInferenceAdapterCalculators() {
    String result = "";
    project.tasks.asMap().forEach((index, task) {
        result += buildInferenceAdapterCalculator(index, task);
    });

    return result;
  }

  String buildInferenceAdapterCalculator(int index, Task task) {
    return """

        node {
        calculator : "OpenVINOInferenceAdapterCalculator"
        output_side_packet : "INFERENCE_ADAPTER:adapter_$index"
        node_options: {
          [type.googleapis.com/mediapipe.OpenVINOInferenceAdapterCalculatorOptions] {
              model_path: "${platformContext.join(project.storagePath, task.modelPaths[0]).replaceAll("\\", "/")}"
              device: "$device"
          }
        }
        }
    """;
  }

  String buildInferenceCalculator(int adapter, Task task, [String inputStream = "input", String outputStream = "inference_result"]) {
    return """
      node {
        calculator : "${task.calculatorName()}Calculator"
        input_side_packet : "INFERENCE_ADAPTER:adapter_$adapter"
        input_stream : "IMAGE:$inputStream"
        output_stream: "INFERENCE_RESULT:$outputStream"
      }
    """;
  }

  Future<String> buildOverlayCalculator() async {
    final font = (await fontPath()).replaceAll("\\", "/");
    return """
      node {
        calculator : "OverlayCalculator"
        input_stream : "IMAGE:input"
        input_stream : "INFERENCE_RESULT:inference_result"
        output_stream : "IMAGE:overlay"
        node_options: {
          [type.googleapis.com/mediapipe.OverlayCalculatorOptions] {
            ${buildOverlayOptions()}
            ${labelSettings()}
            font_path: "$font"
          }
        }
      }
    """;
  }

  String labelSettings() {
    return """
      stroke_width: 2
      opacity: 0.4
      font_size: 1.0
    """;
  }

  String buildOverlayOptions() {
    final labels = project.tasks.map((task) {
      return task.labels.map((label) {
        return """
          labels: {
              id: "${label.id}"
              name: "${label.name}"
              color: "${label.color}"
              is_empty: ${label.isEmpty ? "true" : "false"}
          }
        """;
      }).join("");
    }).join("");

    return """
      $labels
    """;
  }

  String buildSerializationCalculator() {

    return """
      node {
          calculator : "SerializationCalculator"
          input_stream : "INFERENCE_RESULT:inference_result"
          input_stream : "OVERLAY:overlay"
          input_stream : "OUTPUT:serialization_output"
          output_stream: "RESULT:output"
      }
    """;
  }
}
