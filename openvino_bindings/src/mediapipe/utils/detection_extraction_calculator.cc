/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "detection_extraction_calculator.h"

#include <memory>
#include <string>
#include <vector>

#include "src/mediapipe/inference/utils.h"

namespace mediapipe {

absl::Status DetectionExtractionCalculator::GetContract(
    CalculatorContract *cc) {
  LOG(INFO) << "DetectionExtractionCalculator::GetContract()";
  cc->Inputs().Tag("DETECTIONS").Set<geti::InferenceResult>().Optional();
  cc->Inputs().Tag("INFERENCE_RESULT").Set<geti::InferenceResult>().Optional();
  cc->Outputs()
      .Tag("RECTANGLE_PREDICTION")
      .Set<std::vector<geti::RectanglePrediction>>()
      .Optional();

  cc->Outputs()
      .Tag("DETECTED_OBJECTS")
      .Set<std::vector<geti::RectanglePrediction>>()
      .Optional();
  return absl::OkStatus();
}

absl::Status DetectionExtractionCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "DetectionExtractionCalculator::GetiOpen()";
  return absl::OkStatus();
}

absl::Status DetectionExtractionCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "DetectionExtractionCalculator::GetiProcess()";

  std::string input_tag =
      geti::get_input_tag("INFERENCE_RESULT", {"DETECTIONS"}, cc);

  const auto &result = cc->Inputs().Tag(input_tag).Get<geti::InferenceResult>();
  auto detections = std::make_unique<std::vector<geti::RectanglePrediction>>(
      result.rectangles);

  std::string tag =
      geti::get_output_tag("RECTANGLE_PREDICTION", {"DETECTED_OBJECTS"}, cc);
  cc->Outputs().Tag(tag).Add(detections.release(), cc->InputTimestamp());
  return absl::OkStatus();
}

absl::Status DetectionExtractionCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "DetectionExtractionCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(DetectionExtractionCalculator);

}  // namespace mediapipe
