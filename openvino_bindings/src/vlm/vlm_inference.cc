/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include <fstream>
#include <nlohmann/json.hpp>

#include "vlm_inference.h"
#include "load_image.hpp"
#include <opencv2/opencv.hpp>

#include "src/image/json_serialization.h"

bool print_subword(std::string&& subword)
{
    return !(std::cout << subword << std::flush);
}

std::string join_texts(const std::vector<std::string>& texts)
{
    std::ostringstream oss;
    for (size_t i = 0; i < texts.size(); ++i)
    {
        oss << texts[i];
        if (i < texts.size() - 1)
        {
            oss << " "; // Add a space between words but not after the last one
        }
    }
    return oss.str();
}

void VLMInference::set_streamer(const std::function<void(const std::string& response)> callback) {
    streamer = [callback, this](std::string word) {
        if (_stop) {
            _done = true;
            streamer_lock.unlock();
            cond.notify_all();
            return true;
        }
        callback(word.c_str());
        return false;
    };
}


VLMStringWithMetrics VLMInference::prompt(std::string message, int max_new_tokens)
{
    _stop = false;

    std::lock_guard<std::mutex> guard(pipe_mutex);

    const auto t1 = std::chrono::steady_clock::now();

    ov::genai::GenerationConfig generation_config;
    generation_config.max_new_tokens = 100;

    if (streamer)
    {
        streamer_lock.lock();
    }
    _done = false;

    const ov::genai::DecodedResults results = update_images && !imagePaths.empty()
                                                  ? ov_pipe->generate(message,
                                                                      ov::genai::images(
                                                                          utils::load_images(imagePaths)
                                                                      ),
                                                                      ov::genai::generation_config(generation_config),
                                                                      ov::genai::streamer(streamer))
                                                  : ov_pipe->generate(message,
                                                                      ov::genai::generation_config(generation_config),
                                                                      ov::genai::streamer(streamer));


    update_images = false; // Do not reload images on next message, except when setImagePaths is called before.

    if (streamer)
    {
        streamer_lock.unlock();
        cond.notify_all();
    }

    _done = true;


    auto texts = results.texts;

    // Make Metrics
    const auto t2 = std::chrono::steady_clock::now();

    const auto generate_time = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count();

    const auto load_time_f = static_cast<float>(load_time);
    const auto generate_time_f = static_cast<float>(generate_time);
    const auto metrics = VLMMetrics{
        !std::isnan(load_time_f) ? load_time_f : 0.0f,
        !std::isnan(generate_time_f) ? generate_time_f : 0.0f,
    };

    // Return
    auto res = VLMStringWithMetrics{strdup(join_texts(texts).c_str()), metrics};
    return res;
}

void VLMInference::setImagePaths(std::vector<std::string> paths)
{
    imagePaths = paths;
    update_images = true;
}

void VLMInference::force_stop()
{
    // This lock comes free after generation is complete
    // During generation, it's not safe to dispose class as OV may still write to memory
    std::lock_guard<std::mutex> guard(pipe_mutex);
    ov_pipe->finish_chat();

    // Stop streamer
    _stop = true;
    std::unique_lock<std::mutex> lock(streamer_lock);
    while(!_done) {
        cond.wait(lock);
    }

}


bool VLMInference::has_model_index() const
{
    std::ifstream ifs(model_path + "/model_index.json");
    auto r = nlohmann::json::parse(ifs);
    return r.find("chat_template") != r.end();
}
