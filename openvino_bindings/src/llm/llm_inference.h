#ifndef LLM_INFERENCE_H_
#define LLM_INFERENCE_H_

#include <optional>
#include <cmath>

#include "openvino/genai/llm_pipeline.hpp"
#include "metrics.h"

inline float nan_safe(const float& value){
  if (std::isnan(value)) {
    return 0.0f;
  } else {
    return value;
  }
}

class LLMInference {
  ov::genai::LLMPipeline pipe;
  ov::genai::ChatHistory history;
  std::function<bool(std::string)> streamer;
  public:
    LLMInference(std::string model_path, std::string device): model_path(model_path), pipe(model_path, device) {}
    void set_streamer(const std::function<void(const std::string& response)> callback);
    std::string prompt(std::string message, float temperature, float top_p);
    void clear_history();
    void force_stop();
    bool has_chat_template();
    Metrics get_metrics();

    std::optional<ov::genai::PerfMetrics> metrics = {};
  private:
    bool _stop = false;
    std::string model_path;


};


#endif // LLM_INFERENCE_H_
