/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef CROP_CALCULATOR_H
#define CROP_CALCULATOR_H

#include <models/results.h>

#include "src/image/data_structures.h"
#include "src/mediapipe/inference/geti_calculator_base.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/image.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/opencv_core_inc.h"
#include "mediapipe/framework/port/status.h"

namespace mediapipe {

// Runs detection inference on the provided image and OpenVINO model.
//
// Input:
//  IMAGE - cv::Mat
//  DETECTION - DetectedObject
//
// Output:
//  IMAGE - cv::Mat, Cropped image based on detection
//

class CropCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;
};

}  // namespace mediapipe

#endif  // CROP_CALCULATOR_H
