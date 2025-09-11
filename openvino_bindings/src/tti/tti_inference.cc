/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include <fstream>
#include <nlohmann/json.hpp>

#include "src/utils/tti_metrics.h"
#include "tti_inference.h"
#include <opencv2/opencv.hpp>

#include "src/image/json_serialization.h"

StringWithMetrics TTIInference::prompt(std::string message, int width, int height, int rounds)
{
    _stop = false;
    //std::lock_guard<std::mutex> guard(pipe_mutex);
    const auto t1 = std::chrono::steady_clock::now();

    _done = false;
    streamer_lock.lock();
    const ov::Tensor tensor = ov_pipe.generate(message,
                                            ov::genai::width(width),
                                            ov::genai::height(height),
                                            ov::genai::num_inference_steps(rounds),
                                            ov::genai::num_images_per_prompt(1),
                                            ov::genai::callback(streamer));
    streamer_lock.unlock();
    cond.notify_all();
    _done = true;

    if (_stop) { // generate got interrupted, return empty
        throw api_error(StatusEnum::ErrorStatus, "Prompt interrupted...");
    }
    const auto imgDataString = tensor_to_encoded_string(tensor);

    // Make Metrics
    const auto t2 = std::chrono::steady_clock::now();

    const auto generate_time = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();

    const auto load_time_f = static_cast<float>(load_time);
    const auto generate_time_f = static_cast<float>(generate_time);
    const auto metrics = TTIMetrics{
        !std::isnan(load_time_f) ? load_time_f : 0.0f,
        !std::isnan(generate_time_f) ? generate_time_f : 0.0f,
    };

    // Return
    auto res = StringWithMetrics{strdup(imgDataString.c_str()), metrics};
    return res;
}

std::string TTIInference::tensor_to_encoded_string(const ov::Tensor& tensor) {
    auto* tensor_data = tensor.data<uint8_t>();

    // Get the shape of the tensor [1, 512, 512, 3]
    const auto shape = tensor.get_shape();
    const auto batch_size_ = shape[0];
    const auto height_ = shape[1];
    const auto width_ = shape[2];
    const auto channels_ = shape[3];

    // Ensure the tensor has the shape [1, 512, 512, 3]
    if (batch_size_ != 1 || channels_ != 3)
    {
        throw api_error(StatusEnum::ErrorStatus, "Unsupported tensor shape");
    }

    const cv::Mat image(static_cast<int>(height_), static_cast<int>(width_), CV_8UC3, tensor_data);
    if (!flip_bgr)
    {
        cv::cvtColor(image, image, cv::COLOR_BGR2RGB);
    }
    return geti::base64_encode_mat(image);

}

void TTIInference::set_streamer(const std::function<void(const StringWithMetrics& response, int step, int rounds)> callback) {
    streamer = [callback, this](size_t step, size_t num_steps, ov::Tensor& latent) {
        if (_stop) {
            _done = true;
            streamer_lock.unlock();
            cond.notify_all();
            return true;
        }

        ov::Tensor tensor = ov_pipe.decode(latent); // get intermediate image tensor
        const auto imgDataString = tensor_to_encoded_string(tensor);
        callback(StringWithMetrics{strdup(imgDataString.c_str()), TTIMetrics{}}, step, num_steps);
        return false;
    };
}

void TTIInference::force_stop() {
    _stop = true;
    std::unique_lock<std::mutex> lock(streamer_lock);
    while(!_done) {
        cond.wait(lock);
    }
}


void TTIInference::stop()
{
    // This lock comes free after generation is complete
    // During generation, it's not safe to dispose class as OV may still write to memory
    std::lock_guard<std::mutex> guard(pipe_mutex);
}


bool TTIInference::has_model_index() const
{
    std::ifstream ifs(model_path + "/model_index.json");
    auto r = nlohmann::json::parse(ifs);
    return r.find("chat_template") != r.end();
}
