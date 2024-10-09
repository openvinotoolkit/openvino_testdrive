#include "serialization_calculators.h"

#include <nlohmann/json.hpp>

#include "src/mediapipe/inference/utils.h"
#include "src/image/csv_serialization.h"
#include "src/image/json_serialization.h"
#include "src/image/data_structures.h"

namespace mediapipe {

absl::Status SerializationCalculator::GetContract(CalculatorContract *cc) {
  LOG(INFO) << "SerializationCalculator::GetContract()";
  cc->Inputs().Tag("OVERLAY").Set<cv::Mat>().Optional();
  cc->Inputs().Tag("OUTPUT").Set<SerializationOutput>();
  cc->Inputs().Tag("INFERENCE_RESULT").Set<geti::InferenceResult>();

  cc->Outputs().Tag("RESULT").Set<std::string>();


  return absl::OkStatus();
}

absl::Status SerializationCalculator::GetiOpen(CalculatorContext *cc) {
  LOG(INFO) << "SerializationCalculator::GetiOpen()";
  return absl::OkStatus();
}

absl::Status SerializationCalculator::GetiProcess(CalculatorContext *cc) {
  LOG(INFO) << "SerializationCalculator::GetiProcess()";
  auto result = cc->Inputs().Tag("INFERENCE_RESULT").Get<geti::InferenceResult>();

  bool include_xai = false;

  if (!include_xai) {
    result.saliency_maps.clear();
  }
  auto selected_output = cc->Inputs().Tag("OUTPUT").Get<SerializationOutput>();

  nlohmann::json output = {};
  if (output_json || selected_output.json) {
    output["json"] = result;
    if (!include_xai) {
        output["json"].erase("maps");  // Remove empty array added by serializer.
    }
  }

  if (output_csv || selected_output.csv) {
    output["csv"] = geti::csv_serialize(result);
  }

  if (output_overlay || selected_output.overlay) {
      //Base 64 encode the overlay into the json
    cv::Mat overlay = cc->Inputs().Tag("OVERLAY").Get<cv::Mat>();
    cv::cvtColor(overlay, overlay, cv::COLOR_BGR2RGB);
    output["overlay"] = geti::base64_encode_mat(overlay);
  }

  cc->Outputs()
      .Tag("RESULT")
      .AddPacket(MakePacket<std::string>(output.dump())
                     .At(cc->InputTimestamp()));
  return absl::OkStatus();
}
absl::Status SerializationCalculator::Close(CalculatorContext *cc) {
  LOG(INFO) << "SerializationCalculator::Close()";
  return absl::OkStatus();
}

REGISTER_CALCULATOR(SerializationCalculator);

}  // namespace mediapipe
