/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef CONTOURER_H
#define CONTOURER_H

#include <models/results.h>

#include <condition_variable>
#include <iostream>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>

#include "data_structures.h"

namespace geti {



inline cv::Rect expand_box(const cv::Rect2f& box, float scale) {
    float w_half = box.width * 0.5f * scale,
        h_half = box.height * 0.5f * scale;
    const cv::Point2f& center = (box.tl() + box.br()) * 0.5f;
    return {cv::Point(int(center.x - w_half), int(center.y - h_half)), cv::Point(int(center.x + w_half), int(center.y + h_half))};
}

class Contourer {
 private:
  std::mutex queue_mutex;
  std::condition_variable queue_condition;
  std::mutex store_mutex;

  std::queue<SegmentedObject> jobs;
  std::vector<geti::Label> labels;

  std::vector<std::thread> threads;
  bool should_terminate = false;

 protected:
  const uint32_t num_threads;

 public:
  std::vector<PolygonPrediction> contours;
  Contourer(std::vector<geti::Label> labels)
    : num_threads(std::thread::hardware_concurrency()), labels(labels) {}

  static size_t INSTANCE_THRESHOLD;

  void process();
  void start();
  void queue(const std::vector<SegmentedObject> &objects);
  void stop();
  bool busy();
  void contour(const SegmentedObject &object);
  void position_contour(std::vector<cv::Point> &contour,
                        const cv::Size &mask_size, const cv::Rect &obj);
  void thread_loop();
  void store(const PolygonPrediction &prediction);

  cv::Mat resize(const SegmentedObject& box, const cv::Mat& unpadded, const cv::Rect& area);

};

}  // namespace geti


#endif // CONTOURER_H
