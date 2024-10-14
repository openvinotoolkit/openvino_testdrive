#include <fstream>
#include <nlohmann/json.hpp>

#include "llm_inference.h"
#include "src/utils/errors.h"

void LLMInference::set_streamer(const std::function<void(const std::string& response)> callback) {
    streamer = [callback, this](std::string word) {
        if (_stop) {
            return true;
        }
        callback(word.c_str());
        return false;
    };
}

ov::genai::DecodedResults LLMInference::prompt(std::string message, float temperature, float top_p) {
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

    if (streamer) {
        result = pipe.generate(prompt, config, streamer);
        history.push_back({{"role", "assistant"}, {"content", result}});
    } else {
        result = pipe.generate(prompt, config);
    }

    return result;
}

void LLMInference::clear_history() {
    history.clear();
}

void LLMInference::force_stop() {
    _stop = true;
}

bool LLMInference::has_chat_template() {
    std::ifstream ifs(model_path + "/tokenizer_config.json");
    auto r = nlohmann::json::parse(ifs);
    return r.find("chat_template") != r.end();
}
