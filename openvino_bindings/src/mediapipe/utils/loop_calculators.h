#ifndef LOOP_CALCULATORS_H
#define LOOP_CALCULATORS_H

#include <models/input_data.h>
#include <models/results.h>

#include <vector>

#include "src/mediapipe/inference/geti_calculator_base.h"
#include "mediapipe/calculators/core/begin_loop_calculator.h"
#include "mediapipe/calculators/core/end_loop_calculator.h"
#include "mediapipe/framework/calculator_framework.h"
#include "src/image/data_structures.h"

namespace mediapipe {

using BeginLoopRectanglePredictionCalculator =
    BeginLoopCalculator<std::vector<geti::RectanglePrediction>>;
using EndLoopRectanglePredictionsCalculator =
    EndLoopCalculator<std::vector<geti::RectanglePrediction>>;
using EndLoopPolygonPredictionsCalculator =
    EndLoopCalculator<std::vector<std::vector<geti::PolygonPrediction>>>;

using BeginLoopModelApiDetectionCalculator =
    BeginLoopCalculator<std::vector<geti::RectanglePrediction>>;
using EndLoopModelApiDetectionClassificationCalculator =
    EndLoopCalculator<std::vector<geti::RectanglePrediction>>;
using EndLoopModelApiDetectionSegmentationCalculator =
    EndLoopCalculator<std::vector<std::vector<geti::PolygonPrediction>>>;
}  // namespace mediapipe

#endif  // LOOP_CALCULATORS_H
