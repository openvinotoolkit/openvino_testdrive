#ifndef TTI_INFERENCE_H_
#define TTI_INFERENCE_H_

#include <optional>
#include <cmath>
#include <mutex>
#include <chrono> // Include for time measurement

#include "src/utils/tti_metrics.h"
#include "openvino/genai/image_generation/text2image_pipeline.hpp"

class TTIInference
{
    long load_time = 9999;
    ov::genai::Text2ImagePipeline pipe;
    ov::genai::ChatHistory history;
    std::function<bool(std::string)> streamer;

public:
    TTIInference(std::string model_path, std::string device):
        // Use a lambda to initialize the 'pipe' and measure the construction time in one step
        pipe([&]() {
            auto start_time = std::chrono::steady_clock::now();
            ov::genai::Text2ImagePipeline temp_pipe(model_path, device); // Construct the pipe
            auto end_time = std::chrono::steady_clock::now();

            // Calculate load time
            this->load_time = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count();

            return temp_pipe; // Return the initialized pipe
        }()),
        model_path(model_path)
    {
        // Constructor body can remain empty unless additional initialization is required
    }

    StringWithMetrics prompt(std::string message, int width, int height, int rounds);
    bool has_model_index() const;

private:
    std::string model_path;
};

#endif // TTI_INFERENCE_H_
