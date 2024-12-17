/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef EMPTYLABEL_CALCULATOR_H_
#define EMPTYLABEL_CALCULATOR_H_

#include <models/results.h>

#include "src/mediapipe/inference/geti_calculator_base.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/opencv_core_inc.h"
#include "mediapipe/framework/port/status.h"
#include "src/image/data_structures.h"
#include "src/mediapipe/utils/emptylabel.pb.h"

namespace mediapipe {

// Adds empty label to detection prediction if appropriate.
//
// Input:
//  PREDICTION - ResultObject
//
// Output:
//  PREDICTION - ResultObject
//

class EmptyLabelCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;

  geti::InferenceResult add_global_labels(
      const geti::InferenceResult &prediction,
      const mediapipe::EmptyLabelOptions &options);
  geti::Label get_label_from_options(
      const mediapipe::EmptyLabelOptions &options);
};

using EmptyLabelDetectionCalculator = EmptyLabelCalculator;
using EmptyLabelClassificationCalculator = EmptyLabelCalculator;
using EmptyLabelRotatedDetectionCalculator = EmptyLabelCalculator;
using EmptyLabelSegmentationCalculator = EmptyLabelCalculator;

}  // namespace mediapipe

#endif  // EMPTYLABEL_CALCULATOR_H_
