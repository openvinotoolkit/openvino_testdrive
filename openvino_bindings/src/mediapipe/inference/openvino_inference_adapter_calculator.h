/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef OPENVINO_INFERENCE_ADAPTER_CALCULATOR_H
#define OPENVINO_INFERENCE_ADAPTER_CALCULATOR_H
#include <adapters/inference_adapter.h>

#include <memory>

#include "src/mediapipe/inference/geti_calculator_base.h"
#include "src/mediapipe/inference/openvino_inference_adapter_calculator.pb.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/packet.h"
#include "mediapipe/framework/port/status.h"

namespace mediapipe {

// Create inference adapter on the provided model and device
//
// Input side packet:
//  MODEL_PATH
//  DEVICE
//
// Output side packet:
//  INFERENCE_ADAPTER
//

class OpenVINOInferenceAdapterCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;

 private:
  std::shared_ptr<InferenceAdapter> ia;
};

}  // namespace mediapipe

#endif  // OPENVINO_INFERENCE_ADAPTER_CALCULATOR_H
