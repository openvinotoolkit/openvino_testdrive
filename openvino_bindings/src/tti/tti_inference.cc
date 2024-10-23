#include <fstream>
#include <nlohmann/json.hpp>

#include "tti_inference.h"
#include <opencv2/opencv.hpp>
#include "src/image/json_serialization.h"

std::string TTIInference::prompt(std::string message, int width, int height)
{
    ov::Tensor tensor = pipe.generate(message,
                                     ov::genai::width(width),
                                     ov::genai::height(height),
                                     ov::genai::num_inference_steps(20),
                                     ov::genai::num_images_per_prompt(1));


    uint8_t* tensor_data = tensor.data<uint8_t>();

    // Get the shape of the tensor [1, 512, 512, 3]
    auto shape = tensor.get_shape();
    int batch_size_ = shape[0];
    int height_ = shape[1];
    int width_ = shape[2];
    int channels_ = shape[3];

    // Ensure the tensor has the shape [1, 512, 512, 3]
    if (batch_size_ != 1 || channels_ != 3) {
        std::cerr << "Unsupported tensor shape" << std::endl;
        return "";
    }

    // Reshape the uint8_t data into a 512x512 3-channel OpenCV Mat
    cv::Mat image(height_, width_, CV_8UC3, tensor_data);

    auto res = geti::base64_encode_mat(image);

    return res;
}


bool TTIInference::has_model_index()
{
    std::ifstream ifs(model_path + "/model_index.json");
    auto r = nlohmann::json::parse(ifs);
    return r.find("chat_template") != r.end();
}
