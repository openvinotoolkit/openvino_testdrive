/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#ifndef CAMERA_HANDLER_H_
#define CAMERA_HANDLER_H_

#include <opencv2/opencv.hpp>
#include <functional>
#include <thread>
#include "errors.h"

class CameraHandler {
  int device;
  public:
    CameraHandler(int device): device(device) {}
    void open_camera(const std::function<void(cv::Mat frame)>& onFrameCallback);
    void stop_camera();
    void set_resolution(int width, int height);

  private:
    void start_camera_process(const std::function<void(cv::Mat frame)>& onFrameCallback);

    bool camera_get_frame = false;

    cv::VideoCapture cap;
    std::thread camera_thread;



};



#endif // CAMERA_HANDLER_H_
