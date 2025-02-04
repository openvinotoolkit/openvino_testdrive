/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef GRAPH_RUNNER_H_
#define GRAPH_RUNNER_H_


#include <vector>
#include <memory>
#include "mediapipe/framework/calculator_framework.h"
#include <opencv2/opencv.hpp>
#include "src/utils/camera_handler.h"

class GraphRunner  {
 public:
  GraphRunner():
    graph(std::make_shared<mediapipe::CalculatorGraph>()) {}
  void open_graph(std::string graph_content);
  //void Listen(const std::function<void(const std::string&)> callback);

  template<typename T>
  void queue(std::string name, int timestamp, T content) {
    auto packet = mediapipe::MakePacket<T>(content).At(mediapipe::Timestamp(timestamp));
    graph->AddPacketToInputStream(name, packet);
  }

  std::string get();
  void stop();

  std::shared_ptr<CameraHandler> open_camera(int deviceIndex);
  void stop_camera();

 private:

  // Data stored in these variables is unique to each instance of the add-on.
  int64 timestamp = 0;
  std::shared_ptr<mediapipe::OutputStreamPoller> poller;
  std::shared_ptr<mediapipe::CalculatorGraph> graph;
  std::shared_ptr<CameraHandler> camera_handler;
};


#endif // GRAPH_RUNNER_H_
