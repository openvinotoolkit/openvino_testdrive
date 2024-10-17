#include <condition_variable>
#include <fstream>
#include <nlohmann/json.hpp>

#include "llm_inference.h"
#include "src/utils/errors.h"

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

std::string LLMInference::prompt(std::string message, float temperature, float top_p) {
    history.push_back({{"role", "user"}, {"content", message}});
    _stop = false;

    auto prompt = (has_chat_template()
        ? pipe.get_tokenizer().apply_chat_template(history, true)
        : message);

    ov::genai::GenerationConfig config;
    config.max_new_tokens = 1000;
    config.temperature = temperature;
    config.top_p = top_p;
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

    if (metrics.has_value()) {
        metrics = metrics.value() + result.perf_metrics;
    } else {
        metrics = result.perf_metrics;
    }

    return result;
}

void LLMInference::clear_history() {
    history.clear();
    metrics.reset();
}

void LLMInference::force_stop() {
    _stop = true;
    std::unique_lock<std::mutex> lock(streamer_lock);
    while(!_done) {
        cond.wait(lock);
    }
}

Metrics LLMInference::get_metrics() {
    if (!metrics.has_value()) {
        throw api_error(LLMNoMetricsYet);
    }
    auto m = metrics.value();
    return Metrics{
      nan_safe(m.get_load_time()),
      nan_safe(m.get_generate_duration().mean),
      nan_safe(m.get_tokenization_duration().mean),
      nan_safe(m.get_detokenization_duration().mean),
      nan_safe(m.get_ttft().mean),
      nan_safe(m.get_tpot().mean),
      nan_safe(m.get_throughput().mean),
      int(m.num_generated_tokens),
      int(m.num_input_tokens)
    };
}

bool LLMInference::has_chat_template() {
    std::ifstream ifs(model_path + "/tokenizer_config.json");
    auto r = nlohmann::json::parse(ifs);
    return r.find("chat_template") != r.end();
}
