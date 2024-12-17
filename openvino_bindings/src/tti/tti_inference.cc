/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include <fstream>
#include <nlohmann/json.hpp>

#include "tti_inference.h"
#include <opencv2/opencv.hpp>

#include "src/image/json_serialization.h"

StringWithMetrics TTIInference::prompt(std::string message, int width, int height, int rounds)
{
    std::lock_guard<std::mutex> guard(pipe_mutex);
    const auto t1 = std::chrono::steady_clock::now();

    const ov::Tensor tensor = ov_pipe.generate(message,
                                            ov::genai::width(width),
                                            ov::genai::height(height),
                                            ov::genai::num_inference_steps(rounds),
                                            ov::genai::num_images_per_prompt(1));


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
        std::cerr << "Unsupported tensor shape" << std::endl;
        return StringWithMetrics{"", {}};
    }

    // Reshape the uint8_t data into a 512x512 3-channel OpenCV Mat
    const cv::Mat image(static_cast<int>(height_), static_cast<int>(width_), CV_8UC3, tensor_data);
    if (flip_bgr)
    {
        cv::cvtColor(image, image, cv::COLOR_BGR2RGB);
    }

    const auto imgDataString = geti::base64_encode_mat(image);

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
