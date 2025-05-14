#include "tti/tti_inference.h"
#include <iostream>

int main() {
    std::cout << "init" << std::endl;

    std::string model_path = "/mnt/c/Users/selse/AppData/Roaming/intel.openvino/OpenVINO\ Test\ Drive/LCM_Dreamshaper_v7-int8-ov";


    std::cout << "loading " << model_path << std::endl;

    TTIInference tti(model_path, "CPU");

    auto lambda_callback = [](const StringWithMetrics& response) {
        std::cout << "got one" << std::endl;
    };

    tti.set_streamer(lambda_callback);
    tti.prompt("Piano", 64, 64, 4);

    std::cout << "done" << std::endl;

    return 0;
}
