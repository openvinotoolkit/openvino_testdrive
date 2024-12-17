// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

#include "openvino_inference_adapter_calculator.h"

#include <adapters/openvino_adapter.h>
#include <models/input_data.h>
#include <models/results.h>

#include <memory>
#include <string>
#include <utility>

namespace mediapipe {

absl::Status OpenVINOInferenceAdapterCalculator::GetContract(
    CalculatorContract *cc) {
  LOG(INFO) << "OpenVINOInferenceAdapterCalculator::GetContract()";
  cc->InputSidePackets().Tag("MODEL_PATH").Optional().Set<std::string>();
  cc->InputSidePackets().Tag("DEVICE").Optional().Set<std::string>();
  cc->OutputSidePackets()
      .Tag("INFERENCE_ADAPTER")
      .Set<std::shared_ptr<InferenceAdapter>>();

  return absl::OkStatus();
}

absl::Status OpenVINOInferenceAdapterCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "OpenVINOInferenceAdapterCalculator::GetiOpen()";
  cc->SetOffset(TimestampDiff(0));

  std::string device = "AUTO";
  std::string model_path;
  const auto &options =
      cc->Options<OpenVINOInferenceAdapterCalculatorOptions>();
  if (cc->InputSidePackets().HasTag("MODEL_PATH")) {
    model_path = cc->InputSidePackets().Tag("MODEL_PATH").Get<std::string>();
  } else if (!options.model_path().empty()) {
    model_path = options.model_path();
  }
  if (cc->InputSidePackets().HasTag("DEVICE")) {
    device = cc->InputSidePackets().Tag("DEVICE").Get<std::string>();
  } else if (!options.device().empty()) {
    device = options.device();
  }

  auto core = ov::Core();
  auto model = core.read_model(model_path);
  ia = std::make_shared<OpenVINOInferenceAdapter>();
  ia->loadModel(model, core, device, {});
  cc->OutputSidePackets()
      .Tag("INFERENCE_ADAPTER")
      .Set(MakePacket<std::shared_ptr<InferenceAdapter>>(std::move(ia)));

  return absl::OkStatus();
}

absl::Status OpenVINOInferenceAdapterCalculator::GetiProcess(
    CalculatorContext *cc) {
  LOG(INFO) << "OpenVINOInferenceAdapterCalculator::GetiProcess()";
  return absl::OkStatus();
}

absl::Status OpenVINOInferenceAdapterCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "OpenVINOInferenceAdapterCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(OpenVINOInferenceAdapterCalculator);

}  // namespace mediapipe
