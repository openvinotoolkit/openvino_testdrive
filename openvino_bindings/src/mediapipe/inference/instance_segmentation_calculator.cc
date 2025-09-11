/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "instance_segmentation_calculator.h"

#include <memory>
#include <opencv2/imgproc.hpp>
#include <string>

#include "src/mediapipe/inference/utils.h"
#include "src/image/contourer.h"
#include "src/mediapipe/utils/emptylabel.pb.h"

namespace mediapipe {

absl::Status InstanceSegmentationCalculator::GetContract(
    CalculatorContract *cc) {
  LOG(INFO) << "InstanceSegmentationCalculator::GetContract()";
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

absl::Status InstanceSegmentationCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "InstanceSegmentationCalculator::GetiOpen()";
  cc->SetOffset(TimestampDiff(0));
#ifdef USE_MODELADAPTER
  ia = cc->InputSidePackets()
           .Tag("INFERENCE_ADAPTER")
           .Get<std::shared_ptr<InferenceAdapter>>();
  auto configuration = ia->getModelConfig();
  labels = geti::get_labels_from_configuration(configuration);
  auto property = configuration.find("tile_size");
  if (property == configuration.end()) {
    model = MaskRCNNModel::create_model(ia);
    model->postprocess_semantic_masks = false;
  } else {
    auto model = MaskRCNNModel::create_model(ia);
    tiler = std::unique_ptr<InstanceSegmentationTiler>(
        new InstanceSegmentationTiler(std::move(model), {}));
    tiler->postprocess_semantic_masks = false;
  }

  {
    auto property = configuration.find("use_ellipse_shapes");
    if (property != configuration.end()) {
      use_ellipse_shapes = property->second.as<std::string>() == "True";
    }
  }
#else
  auto model_path = cc->InputSidePackets().Tag("MODEL_PATH").Get<std::string>();
  model = MaskRCNNModel::create_model(model_path);
#endif

  return absl::OkStatus();
}

absl::Status InstanceSegmentationCalculator::GetiProcess(
    CalculatorContext *cc) {
  LOG(INFO) << "InstanceSegmentationCalculator::GetiProcess()";
  if (cc->Inputs().Tag("IMAGE").IsEmpty()) {
    return absl::OkStatus();
  }

  const cv::Mat &cvimage = cc->Inputs().Tag("IMAGE").Get<cv::Mat>();

  std::unique_ptr<InstanceSegmentationResult> inference_result;

  const auto &options = cc->Options<EmptyLabelOptions>();
  std::string label_name =
      options.label().empty() ? geti::GETI_EMPTY_LABEL : options.label();
  std::unique_ptr<geti::InferenceResult> result =
      std::make_unique<geti::InferenceResult>();

  bool isEmpty = false;
  cv::Rect roi(0, 0, cvimage.cols, cvimage.rows);
  result->roi = roi;

  if (tiler) {
    auto tiler_result = tiler->run(cvimage);
    LOG(INFO) << "Using tiling";
    inference_result = std::unique_ptr<InstanceSegmentationResult>(static_cast<InstanceSegmentationResult *>(tiler_result.release()));
  } else {
    inference_result = model->infer(cvimage);
  }

  if (use_ellipse_shapes) {
    for (auto& obj: inference_result->segmentedObjects) {
      float radius = std::max(obj.width, obj.height) / 2;
      result->circles.push_back(
        {{geti::LabelResult{obj.confidence, labels[obj.labelID]}}, geti::Circle{obj.x + obj.width / 2, obj.y + obj.height / 2, radius}});
    }

  } else {
    geti::Contourer contourer(labels);

    if (inference_result->segmentedObjects.size() < geti::Contourer::INSTANCE_THRESHOLD) {
      LOG(INFO) << "Single core post processing since " << inference_result->segmentedObjects.size() << " objects were found";
      for (const auto &obj: inference_result->segmentedObjects) {
        contourer.contour(obj);
      }
    } else {
      LOG(INFO) << "Multi core post processing since " << inference_result->segmentedObjects.size() << " objects were found";
      contourer.queue(inference_result->segmentedObjects);
      contourer.process();
    }
    result->polygons = contourer.contours;
  }

  for (size_t i = 0; i < inference_result->saliency_map.size(); i++) {
    if (labels.size() > i + 1) {
      result->saliency_maps.push_back(
          {inference_result->saliency_map[i], roi, labels[i + 1]});
    }
  }

  std::string tag = geti::get_output_tag("INFERENCE_RESULT", {"RESULT"}, cc);
  cc->Outputs().Tag(tag).Add(result.release(), cc->InputTimestamp());
  return absl::OkStatus();
}

absl::Status InstanceSegmentationCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "InstanceSegmentationCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(InstanceSegmentationCalculator);

}  // namespace mediapipe
