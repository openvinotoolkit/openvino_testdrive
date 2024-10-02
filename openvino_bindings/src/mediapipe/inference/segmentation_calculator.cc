#include "segmentation_calculator.h"

#include <memory>
#include <string>

#include "src/mediapipe/inference/utils.h"
#include "models/image_model.h"
#include "src/image/data_structures.h"

namespace mediapipe {

absl::Status SegmentationCalculator::GetContract(CalculatorContract *cc) {
  LOG(INFO) << "SegmentationCalculator::GetContract()";
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

absl::Status SegmentationCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "SegmentationCalculator::GetiOpen()";
  cc->SetOffset(TimestampDiff(0));
#ifdef USE_MODELADAPTER
  ia = cc->InputSidePackets()
           .Tag("INFERENCE_ADAPTER")
           .Get<std::shared_ptr<InferenceAdapter>>();
  model = SegmentationModel::create_model(ia);
  auto configuration = ia->getModelConfig();
  labels = geti::get_labels_from_configuration(configuration);

  for (const auto &label : labels) {
    labels_map[label.label] = label;
  }

#else
  auto model_path = cc->InputSidePackets().Tag("MODEL_PATH").Get<std::string>();
  model = SegmentationModel::create_model(model_path);
#endif

  return absl::OkStatus();
}

absl::Status SegmentationCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "SegmentationCalculator::GetiProcess()";
  if (cc->Inputs().Tag("IMAGE").IsEmpty()) {
    return absl::OkStatus();
  }

  const cv::Mat &cvimage = cc->Inputs().Tag("IMAGE").Get<cv::Mat>();

  auto inference =
      model->infer(cvimage)->asRef<ImageResultWithSoftPrediction>();
  std::vector<cv::Mat_<std::uint8_t>> saliency_maps_split(
      inference.saliency_map.channels());
  cv::split(inference.saliency_map, saliency_maps_split);

  cv::Rect roi(0, 0, cvimage.cols, cvimage.rows);
  // Insert first, since background label is not supplied by model.xml

  std::unique_ptr<geti::InferenceResult> result =
      std::make_unique<geti::InferenceResult>();
  result->roi = roi;

  for (size_t i = 1; i < saliency_maps_split.size(); i++) {
    if (labels.size() > i - 1)
      result->saliency_maps.push_back(
          {saliency_maps_split[i], roi, labels[i - 1]});
  }

  for (const auto &contour : model->getContours(inference)) {
    std::vector<cv::Point> approxCurve;
    if (contour.shape.size() > 0) {
      cv::approxPolyDP(contour.shape, approxCurve, 1.0f, true);
      if (approxCurve.size() > 2) {
        result->polygons.push_back(
            {{geti::LabelResult{contour.probability,
                                labels_map[contour.label]}},
             approxCurve});
      }
    }
  }

  std::string tag = geti::get_output_tag("INFERENCE_RESULT", {"RESULT"}, cc);
  cc->Outputs().Tag(tag).Add(result.release(), cc->InputTimestamp());
  return absl::OkStatus();
}

absl::Status SegmentationCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "SegmentationCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(SegmentationCalculator);

}  // namespace mediapipe
