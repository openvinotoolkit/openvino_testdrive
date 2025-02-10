/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef LLM_INFERENCE_H_
#define LLM_INFERENCE_H_

#include <optional>
#include <cmath>
#include <mutex>
#include "openvino/genai/llm_pipeline.hpp"

class LLMInference {
  ov::genai::LLMPipeline pipe;
  ov::genai::ChatHistory history;
  std::function<bool(std::string)> streamer;
  public:
    LLMInference(std::string model_path, std::string device):
      model_path(model_path),
      pipe(model_path, device) {}
    void set_streamer(const std::function<void(const std::string& response)> callback);
    ov::genai::DecodedResults prompt(std::string message, bool apply_template, float temperature, float top_p);
    void clear_history();
    void force_stop();
    bool has_chat_template();
    std::string get_tokenizer_config();

    static ov::genai::GenerationConfig config_from_json(std::string configJson);
  private:


    bool _stop = false;
    std::string model_path;
    std::mutex streamer_lock;
    std::condition_variable cond;
    bool _done = true;
};


#endif // LLM_INFERENCE_H_
