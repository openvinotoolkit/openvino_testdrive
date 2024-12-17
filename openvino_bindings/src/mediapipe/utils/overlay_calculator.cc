// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

#include "overlay_calculator.h"
#include "src/mediapipe/utils/overlay_calculator.pb.h"
#include "src/image/utils.h"
#include <filesystem>

namespace mediapipe {

absl::Status OverlayCalculator::GetContract(CalculatorContract *cc) {
  LOG(INFO) << "DetectionOverlayCalculator::GetContract()";
  cc->Inputs().Tag("IMAGE").Set<cv::Mat>();
  cc->Inputs().Tag("INFERENCE_RESULT").Set<geti::InferenceResult>();
  cc->Outputs().Tag("IMAGE").Set<cv::Mat>();

  return absl::OkStatus();
}

absl::Status OverlayCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "DetectionOverlayCalculator::GetiOpen()";
  cc->SetOffset(TimestampDiff(0));

  const auto &options =
      cc->Options<OverlayCalculatorOptions>();
  for (auto &label: options.labels()) {
    label_definitions.push_back(geti::ProjectLabel{
      label.id(),
      label.name(),
      geti::hex_to_color(label.color()),
      label.is_empty()});
  }

  if (options.has_font_size()) {
    draw_options.fontSize = options.font_size();
  }

  if (options.has_opacity()) {
    draw_options.opacity = options.opacity();
  }

  if (options.stroke_width()) {
    draw_options.strokeWidth = options.stroke_width();
  }

  std::cout << std::filesystem::current_path() << std::endl;
  std::string fontPath = options.font_path();
  BLResult result = face.createFromFile(fontPath.c_str());
  if (result != BL_SUCCESS) {
      printf("Failed to load a font (err=%u)\n", result);
  }




  for (auto label: label_definitions) {
    std::cout << label.name << std::endl;
  }

  return absl::OkStatus();
}

absl::Status OverlayCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "DetectionOverlayCalculator::GetiProcess()";
  if (cc->Inputs().Tag("IMAGE").IsEmpty()) {
    return absl::OkStatus();
  }

  // Get inputs
  const cv::Mat &input_image = cc->Inputs().Tag("IMAGE").Get<cv::Mat>();
  auto result =
      cc->Inputs().Tag("INFERENCE_RESULT").Get<geti::InferenceResult>();

  auto overlay = geti::draw_overlay(input_image, result, draw_options, label_definitions, face);
  cv::Mat overlay_rgb;
  cv::cvtColor(overlay, overlay_rgb, cv::COLOR_RGB2BGRA);

  cc->Outputs().Tag("IMAGE").AddPacket(
      MakePacket<cv::Mat>(overlay_rgb).At(cc->InputTimestamp()));

  return absl::OkStatus();
}

absl::Status OverlayCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "DetectionOverlayCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(OverlayCalculator);

}  // namespace mediapipe
