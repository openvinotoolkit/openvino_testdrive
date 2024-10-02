#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

#include <models/results.h>

#include <vector>

namespace geti {
struct Label {
  std::string label_id;
  std::string label;
};

struct SaliencyMap {
  cv::Mat image;
  cv::Rect roi;
  Label label;
};

struct LabelResult {
  float probability;
  Label label;
};

struct PolygonPrediction {
  std::vector<LabelResult> labels;
  std::vector<cv::Point> shape;
};

struct RectanglePrediction {
  std::vector<LabelResult> labels;
  cv::Rect shape;
};

struct RotatedRectanglePrediction {
  std::vector<LabelResult> labels;
  cv::RotatedRect shape;
};

struct Circle {
  float x;
  float y;
  float radius;
};

struct CirclePrediction {
  std::vector<LabelResult> labels;
  Circle shape;
};

struct InferenceResult {
  std::vector<RectanglePrediction> rectangles;
  std::vector<RotatedRectanglePrediction> rotated_rectangles;
  std::vector<PolygonPrediction> polygons;
  std::vector<CirclePrediction> circles;
  std::vector<SaliencyMap> saliency_maps;
  cv::Rect roi;
};
}  // namespace geti

#endif  // DATA_STRUCTURES_H
