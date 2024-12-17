/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef POST_PROCESSING_H_
#define POST_PROCESSING_H_

#include "src/image/contourer.h"
#include "src/image/data_structures.h"
#include "src/utils/errors.h"
#include <memory>

namespace geti {

inline InferenceResult detection_post_processing(std::unique_ptr<ResultBase> result_base, const std::vector<Label>& labels, cv::Mat image) {
  auto inference_result = std::unique_ptr<DetectionResult>(static_cast<DetectionResult*>(result_base.release()));
  InferenceResult result;
  result.roi = cv::Rect(0, 0, image.cols, image.rows);

  for (auto &obj : inference_result->objects) {
    if (labels.size() > obj.labelID)
      result.rectangles.push_back(
          {{geti::LabelResult{obj.confidence, labels[obj.labelID]}}, obj});
  }

  return result;
}

inline InferenceResult classification_post_processing(std::unique_ptr<ResultBase> result_base, const std::vector<Label>& labels, cv::Mat image) {
  auto inference_result = std::unique_ptr<ClassificationResult>(static_cast<ClassificationResult*>(result_base.release()));
  InferenceResult result;
  result.roi = cv::Rect(0, 0, image.cols, image.rows);

  if (inference_result->topLabels.size() > 0) {
    result.rectangles.push_back(geti::RectanglePrediction{{}, result.roi});
    for (const auto &classification : inference_result->topLabels) {
      if (classification.id < labels.size()) {
        result.rectangles[0].labels.push_back(geti::LabelResult{classification.score, labels[classification.id]});
      }
    }
  }

  return result;
}

inline InferenceResult rotated_detection_post_processing(std::unique_ptr<ResultBase> result_base, const std::vector<Label>& labels, cv::Mat image) {
  auto inference_result = std::unique_ptr<InstanceSegmentationResult>(static_cast<InstanceSegmentationResult*>(result_base.release()));
  InferenceResult result;
  result.roi = cv::Rect(0, 0, image.cols, image.rows);

  auto rotated_rects = add_rotated_rects(inference_result->segmentedObjects);

  for (auto &obj : rotated_rects) {
    if (labels.size() > obj.labelID)
      result.rotated_rectangles.push_back(
          {{geti::LabelResult{obj.confidence, labels[obj.labelID]}},
          obj.rotated_rect});
  }

  return result;
}

inline InferenceResult instance_segmentation_post_processing(std::unique_ptr<ResultBase> result_base, const std::vector<Label>& labels, cv::Mat image) {
  auto inference_result = std::unique_ptr<InstanceSegmentationResult>(static_cast<InstanceSegmentationResult*>(result_base.release()));
  InferenceResult result;
  result.roi = cv::Rect(0, 0, image.cols, image.rows);
  geti::Contourer contourer(labels);

  if (inference_result->segmentedObjects.size() < geti::Contourer::INSTANCE_THRESHOLD) {
    for (const auto &obj: inference_result->segmentedObjects) {
      contourer.contour(obj);
    }
  } else {
    contourer.queue(inference_result->segmentedObjects);
    contourer.process();
  }
  result.polygons = contourer.contours;

  return result;
}

inline InferenceResult segmentation_post_processing(std::unique_ptr<ImageResultWithSoftPrediction> inference_result, std::vector<Contour> contours, const std::vector<Label>& labels, cv::Mat image) {
  InferenceResult result;
  result.roi = cv::Rect(0, 0, image.cols, image.rows);

  std::map<std::string, geti::Label> labels_map;
  for (const auto &label : labels) {
    labels_map[label.label] = label;
  }

  for (const auto &contour : contours) {
    std::vector<cv::Point2i> approxCurve;
    if (contour.shape.size() > 0) {
      cv::approxPolyDP(contour.shape, approxCurve, 1.0f, true);
      if (approxCurve.size() > 2) {
        float area = cv::contourArea(approxCurve);
        auto rect = cv::boundingRect(approxCurve);
        result.polygons.push_back(
          {
            {geti::LabelResult{contour.probability, labels_map[contour.label]}},
             approxCurve,
             rect,
             area
          }
        );
      }
    }
  }

  return result;
}

inline InferenceResult anomaly_post_processing(std::unique_ptr<ResultBase> result_base, const std::vector<Label>& labels, cv::Mat image) {
  auto inference_result = std::unique_ptr<AnomalyResult>(static_cast<AnomalyResult*>(result_base.release()));
  InferenceResult result;
  result.roi = cv::Rect(0, 0, image.cols, image.rows);

  if (labels.size() != 2) {
    std::string message = "Anomaly labels: [";
    for (auto &label: labels) {
      message += label.label + ", ";
    }
    message += ']';

    throw api_error(InferenceAnomalyLabelsIncorrect, strdup(message.c_str()));
  }

  auto normal_label = labels[0];
  auto anomalous_label = labels[1];

  auto label = inference_result->pred_label == normal_label.label ? normal_label
                                                              : anomalous_label;

  result.rectangles.push_back({{geti::LabelResult{(float)inference_result->pred_score, label}}, result.roi});

  return result;
}


}

#endif // POST_PROCESSING_H_
