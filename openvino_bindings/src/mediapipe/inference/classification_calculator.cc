/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "classification_calculator.h"

#include <memory>
#include <string>

namespace mediapipe {

absl::Status ClassificationCalculator::GetContract(CalculatorContract *cc) {
  LOG(INFO) << "ClassificationCalculator::GetContract()";
  cc->Inputs().Tag("IMAGE").Set<cv::Mat>();
#ifdef USE_MODELADAPTER
  cc->InputSidePackets()
      .Tag("INFERENCE_ADAPTER")
      .Set<std::shared_ptr<InferenceAdapter>>();
#else
  cc->InputSidePackets().Tag("MODEL_PATH").Set<std::string>();
#endif
  cc->Outputs().Tag("INFERENCE_RESULT").Set<geti::InferenceResult>().Optional();
  cc->Outputs().Tag("CLASSIFICATION").Set<geti::InferenceResult>().Optional();
  return absl::OkStatus();
}

absl::Status ClassificationCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "ClassificationCalculator::GetiOpen()";
  cc->SetOffset(TimestampDiff(0));
#ifdef USE_MODELADAPTER
  ia = cc->InputSidePackets()
           .Tag("INFERENCE_ADAPTER")
           .Get<std::shared_ptr<InferenceAdapter>>();
  auto configuration = ia->getModelConfig();
  labels = geti::get_labels_from_configuration(configuration);
  model = ClassificationModel::create_model(ia);
#else
  auto path_to_model =
      cc->InputSidePackets().Tag("MODEL_PATH").Get<std::string>();
  model = ClassificationModel::create_model(path_to_model);
#endif
  return absl::OkStatus();
}

absl::Status ClassificationCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "ClassificationCalculator::GetiProcess()";
  if (cc->Inputs().Tag("IMAGE").IsEmpty()) {
    return absl::OkStatus();
  }
  LOG(INFO) << "start classification inference";

  // Get image
  const cv::Mat &cvimage = cc->Inputs().Tag("IMAGE").Get<cv::Mat>();

  // Run Inference model
  auto inference_result = model->infer(cvimage);
  std::unique_ptr<geti::InferenceResult> result =
      std::make_unique<geti::InferenceResult>();

  cv::Rect roi(0, 0, cvimage.cols, cvimage.rows);
  result->roi = roi;
  if (inference_result->topLabels.size() > 0) {
    result->rectangles.push_back(geti::RectanglePrediction{{}, roi});
    for (const auto &classification : inference_result->topLabels) {
      if (classification.id < labels.size()) {
        result->rectangles[0].labels.push_back(
            geti::LabelResult{classification.score, labels[classification.id]});
      }
    }

    if (inference_result->saliency_map) {
      size_t shape_shift =
          (inference_result->saliency_map.get_shape().size() > 3) ? 1 : 0;

      for (size_t i = 0; i < labels.size(); i++) {
        result->saliency_maps.push_back(
            {geti::get_mat_from_ov_tensor(inference_result->saliency_map,
                                          shape_shift, i),
             roi, labels[i]});
      }
    }
  }

  std::string tag =
      geti::get_output_tag("INFERENCE_RESULT", {"CLASSIFICATION"}, cc);
  cc->Outputs().Tag(tag).Add(result.release(), cc->InputTimestamp());

  LOG(INFO) << "completed classification inference";
  return absl::OkStatus();
}

absl::Status ClassificationCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "ClassificationCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(ClassificationCalculator);

}  // namespace mediapipe
