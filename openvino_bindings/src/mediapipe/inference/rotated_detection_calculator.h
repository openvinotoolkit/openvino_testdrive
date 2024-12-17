/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ROTATED_DETECTION_CALCULATOR_H_
#define ROTATED_DETECTION_CALCULATOR_H_

#include <models/input_data.h>
#include <models/instance_segmentation.h>
#include <models/results.h>
#include <tilers/instance_segmentation.h>

#include <memory>

#include "src/mediapipe/inference/geti_calculator_base.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/opencv_core_inc.h"
#include "mediapipe/framework/port/status.h"
#include "src/image/data_structures.h"

namespace mediapipe {

// Runs rotated detection inference on the provided image and OpenVINO model.
//
// Input:
//  IMAGE - cv::Mat
//
// Output:
//  DETECTIONS - RotatedDetectionResult
//
// Input side packet:
//  INFERENCE_ADAPTER - std::shared_ptr<InferenceAdapter>
//

class RotatedDetectionCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;

 private:
  std::shared_ptr<InferenceAdapter> ia;
  std::unique_ptr<MaskRCNNModel> model;
  std::unique_ptr<InstanceSegmentationTiler> tiler;
  std::vector<geti::Label> labels;
};

}  // namespace mediapipe

#endif  // ROTATED_DETECTION_CALCULATOR_H_
