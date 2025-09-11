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
#include "src/mediapipe/serialization/serialization_calculators.h"
#include <opencv2/opencv.hpp>
#include "src/utils/camera_handler.h"

class GraphRunner  {
 public:
  int64 timestamp = 0;

  GraphRunner():
    graph(std::make_shared<mediapipe::CalculatorGraph>()) {}
  void open_graph(std::string graph_content);
  //void Listen(const std::function<void(const std::string&)> callback);

  template<typename T>
  void queue(std::string name, int timestamp, T content) {
    if (timestamp > this->timestamp) {
      this->timestamp = timestamp;
    }

    std::cout << "timestamp: " << timestamp << std::endl;
    auto packet = mediapipe::MakePacket<T>(content).At(mediapipe::Timestamp(timestamp));
    graph->AddPacketToInputStream(name, packet);
  }

  std::string get();
  void stop();


  void set_camera_resolution(int width, int height);
  void open_camera(int deviceIndex, SerializationOutput serializationOutput, const std::function<void(std::string output)>& callback);
  void stop_camera();

 private:
  std::shared_ptr<mediapipe::OutputStreamPoller> poller;
  std::shared_ptr<mediapipe::CalculatorGraph> graph;
  std::shared_ptr<CameraHandler> camera_handler;
};


#endif // GRAPH_RUNNER_H_
