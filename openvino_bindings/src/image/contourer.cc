// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

#include "contourer.h"

namespace geti {

// Threshold for switching between single and multi processing
// Experimentally the threshold for faster multi threading was found at 50 instances
size_t Contourer::INSTANCE_THRESHOLD = 50;

void Contourer::process() {
  start();
  while (busy()) {
    std::this_thread::sleep_for(std::chrono::microseconds(10));
  }
  stop();
}

void Contourer::start() {
  for (uint32_t ii = 0; ii < num_threads; ++ii) {
    threads.emplace_back(std::thread(&Contourer::thread_loop, this));
  }
}

void Contourer::queue(const std::vector<SegmentedObject> &objects) {
  {
    std::unique_lock<std::mutex> lock(queue_mutex);
    for (auto &obj : objects) {
      jobs.push(obj);
    }
  }
  queue_condition.notify_one();
}

void Contourer::stop() {
  {
    std::unique_lock<std::mutex> lock(queue_mutex);
    should_terminate = true;
  }
  queue_condition.notify_all();
  for (std::thread &active_thread : threads) {
    active_thread.join();
  }
  threads.clear();
}

bool Contourer::busy() {
  bool poolbusy;
  {
    std::unique_lock<std::mutex> lock(queue_mutex);
    poolbusy = !jobs.empty();
  }
  return poolbusy;
}
void Contourer::contour(const SegmentedObject &object) {
  std::vector<std::vector<cv::Point>> contours;
  cv::Rect extended_box = expand_box(object, float(object.mask.cols) / (object.mask.cols - 2));
  cv::Mat mask = resize(object, object.mask, extended_box);
  cv::threshold(mask, mask, 1, 999, cv::THRESH_OTSU);
  cv::findContours(mask, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_NONE);

  cv::Point offset = extended_box.tl() - cv::Point(object.tl());

  if (contours.size() > 0) {
    double biggest_area = 0.0;
    std::vector<cv::Point> biggest_contour, approxCurve;
    for (auto contour : contours) {
      double area = cv::contourArea(contour);
      if (biggest_area < area) {
        biggest_area = area;
        biggest_contour = contour;
      }
    }

    if (biggest_contour.size() > 0) {
      cv::approxPolyDP(biggest_contour, approxCurve, 1.0f, true);
      if (approxCurve.size() > 2) {
        position_contour(approxCurve, mask.size(), object);
        for (auto& point: approxCurve) {
            point += offset;
        }

        auto rect = cv::boundingRect(approxCurve);

        float area = biggest_area;
        store({
          {geti::LabelResult{object.confidence, labels[object.labelID]}},
          approxCurve,
          rect,
          area
        });
      }
    }
  }
}

void Contourer::position_contour(std::vector<cv::Point> &contour,
                                 const cv::Size &mask_size,
                                 const cv::Rect &obj) {
  for (auto &point : contour) {
    point.x = point.x + obj.x;
    point.y = point.y + obj.y;
  }
}

void Contourer::thread_loop() {
  while (true) {
    SegmentedObject obj;
    bool has_job = false;
    {
      std::unique_lock<std::mutex> lock(queue_mutex);
      queue_condition.wait(
          lock, [this] { return !jobs.empty() || should_terminate; });
      if (should_terminate) {
        return;
      }

      obj = jobs.front();
      jobs.pop();
    }
    contour(obj);
  }
}

void Contourer::store(const PolygonPrediction &prediction) {
  {
    std::unique_lock<std::mutex> lock(store_mutex);
    contours.push_back(prediction);
  }
}

cv::Mat Contourer::resize(const SegmentedObject& box, const cv::Mat& unpadded, const cv::Rect& area) {
    // Add zero border to prevent upsampling artifacts on segment borders.
    cv::Mat raw_cls_mask;
    cv::copyMakeBorder(unpadded, raw_cls_mask, 1, 1, 1, 1, cv::BORDER_CONSTANT, {0});
    cv::Mat resized;
    cv::Mat converted;
    cv::resize(raw_cls_mask, resized, area.size());
    resized.convertTo(converted, CV_8UC1);
    return converted;
}

}  // namespace geti
