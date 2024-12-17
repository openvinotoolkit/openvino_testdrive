/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef CLASSIFICATION_CALCULATOR_H
#define CLASSIFICATION_CALCULATOR_H

#include <adapters/inference_adapter.h>
#include <models/classification_model.h>
#include <models/input_data.h>
#include <models/results.h>

#include <memory>

#include "src/mediapipe/inference/geti_calculator_base.h"
#include "src/mediapipe/inference/utils.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/opencv_core_inc.h"
#include "mediapipe/framework/port/status.h"
#include "src/image/data_structures.h"

namespace mediapipe {

// Runs classification inference on the provided image and OpenVINO model.
//
// Input:
//  IMAGE - cv::Mat
//
// Output:
//  CLASSIFICATION - ClassificationResult
//
// Input side packet:
//  INFERENCE_ADAPTER - std::shared_ptr<InferenceAdapter>
//

class ClassificationCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;

 private:
  std::shared_ptr<InferenceAdapter> ia;
  std::unique_ptr<ClassificationModel> model;
  std::vector<geti::Label> labels;
};

}  // namespace mediapipe

#endif  // CLASSIFICATION_CALCULATOR_H
