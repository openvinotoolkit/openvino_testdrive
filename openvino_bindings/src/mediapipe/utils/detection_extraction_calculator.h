#ifndef DETECTION_EXTRACTION_CALCULATOR_H_
#define DETECTION_EXTRACTION_CALCULATOR_H_

#include <models/detection_model.h>
#include <models/input_data.h>
#include <models/results.h>
#include <tilers/detection.h>

#include <memory>

#include "src/image/data_structures.h"
#include "src/mediapipe/inference/geti_calculator_base.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/port/status.h"

namespace mediapipe {

// Extracts the detected objects vector from an detection result
//
// Input:
//  DETECTIONS - DetectionResult
//
// Output:
//  RECTANGLE_PREDICTION - std::vector<DetectedObject>
//

class DetectionExtractionCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;

 private:
  std::shared_ptr<InferenceAdapter> ia;
  std::unique_ptr<DetectionModel> model;
  std::unique_ptr<DetectionTiler> tiler;
};

}  // namespace mediapipe

#endif  // DETECTION_EXTRACTION_CALCULATOR_H
