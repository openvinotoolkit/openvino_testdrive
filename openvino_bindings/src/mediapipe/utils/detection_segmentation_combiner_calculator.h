/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef DETECTION_SEGMENTATION_COMBINER_CALCULATOR_H_
#define DETECTION_SEGMENTATION_COMBINER_CALCULATOR_H_

#include <models/input_data.h>
#include <models/results.h>

#include "src/image/data_structures.h"
#include "src/mediapipe/inference/geti_calculator_base.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/opencv_core_inc.h"
#include "mediapipe/framework/port/status.h"

namespace mediapipe {

// Outputs image overlaying the detection Segmentation task chain results
//
// Input:
//  DETECTION - DetectedObject
//  SEGMENTATION - Segmentation inference result
//
// Output:
//  DETECTION_SEGMENTATION - Combination object
//

class DetectionSegmentationCombinerCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;
};

}  // namespace mediapipe

#endif  // DETECTION_SEGMENTATION_COMBINER_CALCULATOR_H_
