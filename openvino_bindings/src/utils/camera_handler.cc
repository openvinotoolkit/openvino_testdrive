/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */
#include "camera_handler.h"


void CameraHandler::open_camera(const std::function<void(cv::Mat frame)>& onFrameCallback) {
    camera_get_frame = true;
    camera_thread = std::thread(&CameraHandler::start_camera_process, this, onFrameCallback);
}

void CameraHandler::stop_camera() {
    camera_get_frame = false;
    if (camera_thread.joinable()) {
        camera_thread.join();
    }
}


void CameraHandler::start_camera_process(const std::function<void(cv::Mat frame)>& onFrameCallback) {
    cv::VideoCapture cap;
    std::cout << device << std::endl;
    cap.open(device);
    if (!cap.isOpened()) {
        throw api_error(CameraNotOpenend);
    }

    cv::Mat frame;
    while(camera_get_frame) {
        std::cout << "input..." << std::endl;
        cap.read(frame);
        std::cout << frame.rows << std::endl;
        if (frame.empty()) {
            std::cout << "empty frame" << std::endl;
            continue;
        }
        onFrameCallback(frame);
    }

}
