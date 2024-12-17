/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef TTI_INFERENCE_H_
#define TTI_INFERENCE_H_

#include <mutex>

#include "src/utils/tti_metrics.h"
#include "openvino/genai/image_generation/text2image_pipeline.hpp"

class TTIInference
{
    long load_time = 9999;
    bool flip_bgr = false;
    ov::genai::Text2ImagePipeline ov_pipe;
    std::mutex pipe_mutex;

public:
    TTIInference(std::string model_path, std::string device):
        // Use a lambda to initialize the 'pipe' and measure the construction time in one step
        ov_pipe([&]() {
            auto start_time = std::chrono::steady_clock::now();
            ov::genai::Text2ImagePipeline temp_pipe(model_path, device); // Construct the pipe
            auto end_time = std::chrono::steady_clock::now();

            std::filesystem::path bgr_path = std::filesystem::path(model_path) / "channel_info.json";
            this->flip_bgr = std::filesystem::exists(bgr_path);

            // Calculate load time
            this->load_time = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();

            return temp_pipe; // Return the initialized pipe
        }()),
        model_path(model_path)
    {
        // Constructor body can remain empty unless additional initialization is required
    }

    StringWithMetrics prompt(std::string message, int width, int height, int rounds);
    void stop();
    bool has_model_index() const;

private:
    std::string model_path;
};

#endif // TTI_INFERENCE_H_
