#ifndef INSTANCE_SEGMENTATION_CALCULATOR_H
#define INSTANCE_SEGMENTATION_CALCULATOR_H

#include <models/input_data.h>
#include <models/instance_segmentation.h>
#include <models/results.h>
#include <tilers/instance_segmentation.h>

#include <memory>

#include "src/mediapipe/inference/geti_calculator_base.h"
#include "mediapipe/framework/calculator_framework.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/image_frame_opencv.h"
#include "mediapipe/framework/port/opencv_core_inc.h"
#include "mediapipe/framework/port/status.h"
#include "src/image/data_structures.h"

namespace mediapipe {

// Runs instance segmentation inference on the provided image and OpenVINO
// model.
//
// Input:
//  IMAGE - cv::Mat
//
// Output:
//  RESULT - SegmentationResult
//
// Input side packet:
//  INFERENCE_ADAPTER - std::shared_ptr<InferenceAdapter>
//

class InstanceSegmentationCalculator : public GetiCalculatorBase {
 public:
  static absl::Status GetContract(CalculatorContract *cc);
  absl::Status GetiOpen(CalculatorContext *cc) override;
  absl::Status GetiProcess(CalculatorContext *cc) override;
  absl::Status Close(CalculatorContext *cc) override;

 private:
  std::shared_ptr<InferenceAdapter> ia;
  std::unique_ptr<MaskRCNNModel> model;
  std::unique_ptr<InstanceSegmentationTiler> tiler;
  std::vector<geti::Label> labels;

  bool use_ellipse_shapes = false;
};

}  // namespace mediapipe

#endif  // INSTANCE_SEGMENTATION_CALCULATOR_H
