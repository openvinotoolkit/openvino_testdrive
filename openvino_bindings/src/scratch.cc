#include "tti/tti_inference.h"
#include <iostream>

int main() {
    std::cout << "init" << std::endl;

    std::string model_path = "C:/Users/selse/AppData/Roaming/intel.openvino/OpenVINO\ Test\ Drive/LCM_Dreamshaper_v7-int8-ov";


    std::cout << "loading " << model_path << std::endl;

    TTIInference tti(model_path, "CPU");

    std::cout << "loaded.. " << std::endl;

    auto lambda_callback = [&tti](const StringWithMetrics& response, int n, int n_steps) {
        std::cout << "got " << n << " of " << n_steps << std::endl;

        tti.force_stop();
    };


    tti.set_streamer(lambda_callback);
    tti.prompt("Piano", 64, 64, 4);

    std::cout << "done" << std::endl;

    return 0;
}
