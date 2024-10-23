#ifndef TTI_INFERENCE_H_
#define TTI_INFERENCE_H_

#include <optional>
#include <cmath>
#include <mutex>
#include "openvino/genai/text2image/pipeline.hpp"

class TTIInference
{
    ov::genai::Text2ImagePipeline pipe;
    ov::genai::ChatHistory history;
    std::function<bool(std::string)> streamer;

public:
    TTIInference(std::string model_path, std::string device):
        model_path(model_path),
        pipe(model_path, device)
    {
    }

    std::string prompt(std::string message, int width, int height);
    bool has_model_index();

private:
    std::string model_path;
};


#endif // TTI_INFERENCE_H_
