/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef DATA_STRUCTURES_H_
#define DATA_STRUCTURES_H_

#include <models/results.h>
#include <opencv2/opencv.hpp>
#include <vector>
#include <blend2d.h>

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
  std::vector<cv::Point2i> shape;
  cv::Rect boundingBox;
  float area;
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
  std::vector<SaliencyMap> saliency_maps;
  std::vector<CirclePrediction> circles;
  cv::Rect roi;
};

class ProjectLabel {
public:
  std::string id;
  std::string name;
  BLRgba32 color;
  bool is_empty;
};


}


#endif // DATA_STRUCTURES_H_
