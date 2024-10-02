#include "crop_calculator.h"

#include <memory>

namespace mediapipe {

absl::Status CropCalculator::GetContract(CalculatorContract *cc) {
  LOG(INFO) << "CropCalculator::GetContract()";
  cc->Inputs().Tag("IMAGE").Set<cv::Mat>();
  cc->Inputs().Tag("DETECTION").Set<geti::RectanglePrediction>();
  cc->Outputs().Tag("IMAGE").Set<cv::Mat>();

  return absl::OkStatus();
}

absl::Status CropCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "CropCalculator::GetiOpen()";
  return absl::OkStatus();
}

absl::Status CropCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "CropCalculator::GetiProcess()";
  const cv::Mat &image = cc->Inputs().Tag("IMAGE").Get<cv::Mat>();
  const auto &detection =
      cc->Inputs().Tag("DETECTION").Get<geti::RectanglePrediction>();
  cv::Mat croppedImage = image(detection.shape).clone();
  cc->Outputs().Tag("IMAGE").AddPacket(
      MakePacket<cv::Mat>(croppedImage).At(cc->InputTimestamp()));
  return absl::OkStatus();
}

absl::Status CropCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "CropCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(CropCalculator);

}  // namespace mediapipe
