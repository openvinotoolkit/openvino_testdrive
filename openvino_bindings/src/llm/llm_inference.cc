/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include <condition_variable>
#include <fstream>
#include <nlohmann/json.hpp>
#include <sstream>

#include "llm_inference.h"
#include "src/utils/errors.h"
#include "src/utils/json_utils.h"

void LLMInference::set_streamer(const std::function<void(const std::string& response)> callback) {
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

ov::genai::DecodedResults LLMInference::prompt(std::string message, bool apply_template, float temperature, float top_p) {
    history.push_back({{"role", "user"}, {"content", message}});
    _stop = false;

    //auto prompt = (apply_template && has_chat_template()
    //    ? pipe.get_tokenizer().apply_chat_template(history, true)
    //    : message);
    auto prompt = message;

    ov::genai::GenerationConfig config;
    config.max_new_tokens = 1000;
    config.temperature = temperature;
    config.top_p = top_p;
    config.repetition_penalty = 1.1;
    ov::genai::DecodedResults result;

    _done = false;
    if (streamer) {
        streamer_lock.lock();
        result = pipe.generate(prompt, config, streamer);
        streamer_lock.unlock();
        cond.notify_all();
        history.push_back({{"role", "assistant"}, {"content", result}});
    } else {
        result = pipe.generate(prompt, config);
    }
    _done = true;

    return result;
}

void LLMInference::clear_history() {
    history.clear();
}

void LLMInference::force_stop() {
    _stop = true;
    std::unique_lock<std::mutex> lock(streamer_lock);
    while(!_done) {
        cond.wait(lock);
    }
}

bool LLMInference::has_chat_template() {
    std::ifstream ifs(model_path + "/tokenizer_config.json");
    auto r = nlohmann::json::parse(ifs);
    return r.find("chat_template") != r.end();
}

std::string LLMInference::get_tokenizer_config() {
    std::ifstream ifs(model_path + "/tokenizer_config.json");
    std::ostringstream oss;
    oss << ifs.rdbuf();
    return oss.str();
}

ov::genai::GenerationConfig LLMInference::config_from_json(std::string config_json) {
    ov::genai::GenerationConfig config;
    nlohmann::json data = nlohmann::json::parse(config_json);
    read_json_param(data, "max_new_tokens", config.max_new_tokens);
    read_json_param(data, "temperature", config.temperature);
    read_json_param(data, "top_p", config.top_p);
    read_json_param(data, "repetition_penalty", config.repetition_penalty);
    read_json_param(data, "num_beams", config.num_beams);
    read_json_param(data, "num_return_sequences", config.num_return_sequences);
    read_json_param(data, "num_beam_groups", config.num_beam_groups);
    return config;
}
