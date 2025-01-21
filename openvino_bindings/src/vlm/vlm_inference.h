/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef VLM_INFERENCE_H_
#define VLM_INFERENCE_H_

#include <condition_variable>
#include "src/utils/utils.h"
#include "openvino/genai/visual_language/pipeline.hpp"

class VLMInference
{
    long load_time = 9999;
    std::unique_ptr<ov::genai::VLMPipeline> ov_pipe;
    std::mutex pipe_mutex;
    std::function<bool(std::string)> streamer;

public:
    VLMInference(std::string model_path, std::string device):
        // Use a lambda to initialize the 'pipe' and measure the construction time in one step
        ov_pipe(nullptr), model_path(model_path)
    {
        auto start_time = std::chrono::steady_clock::now();

        ov::AnyMap enable_compile_cache;
        if (device == "GPU") {
            // Cache compiled models on disk for GPU to save time on the
            // next run. It's not beneficial for CPU.
            enable_compile_cache.insert({ov::cache_dir(model_path + "/cache")});
        }

        ov_pipe = std::make_unique<ov::genai::VLMPipeline>(model_path, device, enable_compile_cache);
        ov_pipe->start_chat();

        auto end_time = std::chrono::steady_clock::now();

        std::filesystem::path bgr_path = std::filesystem::path(model_path) / "channel_info.json";
        this->flip_bgr = std::filesystem::exists(bgr_path);

        // Calculate load time
        this->load_time = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();
    }


    VLMStringWithMetrics prompt(std::string message, int max_new_tokens);
    void set_streamer(std::function<void(const std::string& response)> callback);
    void setImagePaths(std::vector<std::string> paths);
    void force_stop();
    bool has_model_index() const;

private:
    std::string model_path;

    bool _stop = false;
    std::mutex streamer_lock;
    std::condition_variable cond;
    bool _done = true;

    bool update_images = true;
    std::vector<std::string> imagePaths;
    bool flip_bgr = false;

};

#endif // VLM_INFERENCE_H_
