/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "anomaly_calculator.h"

#include <memory>
#include <string>

#include "src/mediapipe/inference/utils.h"
#include "models/image_model.h"
#include "src/image/data_structures.h"

namespace mediapipe {

absl::Status AnomalyCalculator::GetContract(CalculatorContract *cc) {
  LOG(INFO) << "AnomalyCalculator::GetContract()";
  cc->Inputs().Tag("IMAGE").Set<cv::Mat>();
#ifdef USE_MODELADAPTER
  cc->InputSidePackets()
      .Tag("INFERENCE_ADAPTER")
      .Set<std::shared_ptr<InferenceAdapter>>();
#else
  cc->InputSidePackets().Tag("MODEL_PATH").Set<std::string>();
#endif
  cc->Outputs().Tag("INFERENCE_RESULT").Set<geti::InferenceResult>().Optional();
  cc->Outputs().Tag("RESULT").Set<geti::InferenceResult>().Optional();
  return absl::OkStatus();
}

absl::Status AnomalyCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "AnomalyCalculator::GetiOpen()";
  cc->SetOffset(TimestampDiff(0));
#ifdef USE_MODELADAPTER
  ia = cc->InputSidePackets()
           .Tag("INFERENCE_ADAPTER")
           .Get<std::shared_ptr<InferenceAdapter>>();

  auto configuration = ia->getModelConfig();
  auto task_iter = configuration.find("task");
  if (task_iter != configuration.end()) {
    task = task_iter->second.as<std::string>();
  }
  auto labels = geti::get_labels_from_configuration(configuration);
  normal_label = labels[0];
  anomalous_label = labels[1];

  model = AnomalyModel::create_model(ia);
#else
  auto model_path = cc->InputSidePackets().Tag("MODEL_PATH").Get<std::string>();
  model = AnomalyModel::create_model(model_path);
#endif

  return absl::OkStatus();
}

absl::Status AnomalyCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "AnomalyCalculator::GetiProcess()";
  if (cc->Inputs().Tag("IMAGE").IsEmpty()) {
    return absl::OkStatus();
  }

  const cv::Mat &cvimage = cc->Inputs().Tag("IMAGE").Get<cv::Mat>();

  auto infer_result = model->infer(cvimage);

  auto result = std::make_unique<geti::InferenceResult>();

  cv::Rect image_roi(0, 0, cvimage.cols, cvimage.rows);
  result->roi = image_roi;

  auto label = infer_result->pred_label == normal_label.label ? normal_label
                                                              : anomalous_label;

  result->rectangles.push_back(
      {{geti::LabelResult{(float)infer_result->pred_score, label}}, image_roi});

  bool FEATURE_FLAG_ANOMALY_REDUCTION = getEnvVar("FEATURE_FLAG_ANOMALY_REDUCTION") == "true";
  std::cout << getEnvVar("FEATURE_FLAG_ANOMALY_REDUCTION") << std::endl;
  std::cout << !FEATURE_FLAG_ANOMALY_REDUCTION << std::endl;
  std::cout << task << std::endl;

  if (!FEATURE_FLAG_ANOMALY_REDUCTION) {
    if (infer_result->pred_label != normal_label.label) {
      if (task == "detection") {
        for (auto &box : infer_result->pred_boxes) {
          double box_score;
          cv::minMaxLoc(infer_result->anomaly_map(box), NULL, &box_score);

          result->rectangles.push_back(
              {{geti::LabelResult{(float)box_score / 255, anomalous_label}},
              box});
        }
      }
      if (task == "segmentation") {
        cv::Mat mask;
        cv::threshold(infer_result->pred_mask, mask, 0, 255, cv::THRESH_BINARY);
        double box_score;
        std::vector<std::vector<cv::Point>> contours, approxCurve;
        cv::findContours(mask, contours, cv::RETR_EXTERNAL,
                        cv::CHAIN_APPROX_SIMPLE);

        for (size_t i = 0; i < contours.size(); i++) {
          std::vector<cv::Point> approx;
          if (contours[i].size() > 0) {
            cv::approxPolyDP(contours[i], approx, 1.0f, true);
            if (approx.size() > 2) approxCurve.push_back(approx);
          }
        }
        for (size_t i = 0; i < approxCurve.size(); i++) {
          cv::Mat contour_mask =
              cv::Mat::zeros(infer_result->anomaly_map.size(), CV_8UC1);
          cv::drawContours(contour_mask, approxCurve, i, 255, -1);
          cv::minMaxLoc(infer_result->anomaly_map, &box_score, 0, 0, 0,
                        contour_mask);

          result->polygons.push_back(
              {{geti::LabelResult{(float)box_score / 255, anomalous_label}},
              approxCurve[i]});
        }
      }
    }
  }

  std::cout << "n polygons: " << result->polygons.size() << std::endl;

  result->saliency_maps.push_back(
      {infer_result->anomaly_map, image_roi, label});

  std::string tag = geti::get_output_tag("INFERENCE_RESULT", {"RESULT"}, cc);
  cc->Outputs().Tag(tag).Add(result.release(), cc->InputTimestamp());

  return absl::OkStatus();
}

absl::Status AnomalyCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "AnomalyCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(AnomalyCalculator);

}  // namespace mediapipe
