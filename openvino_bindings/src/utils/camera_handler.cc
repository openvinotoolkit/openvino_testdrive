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

void CameraHandler::set_resolution(int width, int height) {
    if (width > 0) {
        cap.set(cv::CAP_PROP_FRAME_WIDTH, width);
    }
    if (height > 0) {
        cap.set(cv::CAP_PROP_FRAME_HEIGHT, height);
    }
}

void CameraHandler::start_camera_process(const std::function<void(cv::Mat frame)>& onFrameCallback) {
    cap = cv::VideoCapture(device);
    std::cout << "opening device: " << std::endl;
    std::cout << device << std::endl;
    if (!cap.isOpened()) {
        throw api_error(CameraNotOpenend);
    }

    cv::Mat frame;
    while(camera_get_frame) {
        std::cout << "input..." << std::endl;
        cap.read(frame);
        std::cout << frame.cols << "x" << frame.rows << std::endl;
        if (frame.empty()) {
            std::cout << "empty frame" << std::endl;
            continue;
        }
        onFrameCallback(frame);
    }

}
