#include "emptylabel_calculator.h"

#include <memory>

#include "src/image/data_structures.h"

namespace mediapipe {

absl::Status EmptyLabelCalculator::GetContract(CalculatorContract *cc) {
  LOG(INFO) << "EmptyLabelCalculator::GetContract()";
  cc->Inputs().Tag("PREDICTION").Set<geti::InferenceResult>();
  cc->Outputs().Tag("PREDICTION").Set<geti::InferenceResult>();

  return absl::OkStatus();
}

absl::Status EmptyLabelCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "EmptyLabelCalculator::GetiOpen()";
  return absl::OkStatus();
}

absl::Status EmptyLabelCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "EmptyLabelCalculator::GetiProcess()";
  auto prediction = cc->Inputs().Tag("PREDICTION").Get<geti::InferenceResult>();
  size_t n_predictions = prediction.polygons.size() +
                         prediction.rectangles.size() +
                         prediction.circles.size() +
                         prediction.rotated_rectangles.size();
  if (n_predictions == 0) {
    const auto &options = cc->Options<EmptyLabelOptions>();
    auto label = get_label_from_options(options);
    prediction.rectangles.push_back(
        {{geti::LabelResult{0.0f, label}}, prediction.roi});
  }

  cc->Outputs()
      .Tag("PREDICTION")
      .AddPacket(MakePacket<geti::InferenceResult>(prediction)
                     .At(cc->InputTimestamp()));

  return absl::OkStatus();
}

absl::Status EmptyLabelCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "EmptyLabelCalculator::Close()";
  return absl::OkStatus();
}

geti::Label EmptyLabelCalculator::get_label_from_options(
    const mediapipe::EmptyLabelOptions &options) {
  std::string label_name = options.label().empty() ? "empty" : options.label();
  return {options.id(), label_name};
}

REGISTER_CALCULATOR(EmptyLabelCalculator);
REGISTER_CALCULATOR(EmptyLabelDetectionCalculator);
REGISTER_CALCULATOR(EmptyLabelClassificationCalculator);
REGISTER_CALCULATOR(EmptyLabelRotatedDetectionCalculator);
REGISTER_CALCULATOR(EmptyLabelSegmentationCalculator);

}  // namespace mediapipe
