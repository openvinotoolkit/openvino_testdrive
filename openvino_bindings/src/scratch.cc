#include "tti/tti_inference.h"
#include <iostream>
#include <thread>


//void start_model(TTIInference& tti) {
//    tti.prompt("Piano", 64, 64, 4);
//}

int main() {
    std::cout << "init" << std::endl;

    std::string model_path = "/mnt/c/Users/selse/AppData/Roaming/intel.openvino/OpenVINO\ Test\ Drive/LCM_Dreamshaper_v7-int8-ov";


    std::cout << "loading " << model_path << std::endl;

    TTIInference tti(model_path, "CPU");

    std::cout << "loaded.. " << std::endl;

    auto lambda_callback = [&tti](const StringWithMetrics& response, int n, int n_steps) {
        std::cout << "got " << n << " of " << n_steps << std::endl;
    };


    tti.set_streamer(lambda_callback);
    std::cout << "starting prompt" << std::endl;
    std::thread start_t(&TTIInference::prompt, &tti, "Piano", 64, 64, 4);
    //tti.prompt("Piano", 64, 64, 4);
    //

    std::cout << "sleeping prompt" << std::endl;
    std::this_thread::sleep_for (std::chrono::seconds(1));
    std::cout << "forcing stop" << std::endl;
    tti.force_stop();
    std::cout << "joining prompt thread" << std::endl;
    start_t.join();
    std::cout << "done" << std::endl;
    return 0;
}
