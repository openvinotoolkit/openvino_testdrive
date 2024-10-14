#include <iostream>
#include <fstream>

#include "openvino/genai/whisper_pipeline.hpp"
#include "src/audio/speech_to_text.h"
#include "src/audio/audio_grabber.h"


void run_whisper_model(std::vector<float> raw_speech) {
    std::string model_path = "/data/genai/whisper-base";

    ov::genai::WhisperPipeline pipeline(model_path, "CPU");
    ov::genai::WhisperGenerationConfig config{model_path + "/generation_config.json"};
    config.max_new_tokens = 100;

    std::cout << pipeline.generate(raw_speech, config) << std::endl;

}

void test_audio_grabber(std::string filename, int start_time, int duration) {
    AudioGrabber grabber(filename);
    for (int start_time = 0; start_time < 10; start_time += duration) {
        auto section = grabber.grab_chunk(start_time, duration);
        run_whisper_model(section);
    }
}

int main(){
    std::cout << "Scratch" << std::endl;

    std::string model_path = "C:/data/genai/whisper-base";
    std::string filename = "C:/data/test_audio.mp4";
    int start_time = 0;
    int duration = 2;

    {
        SpeechToText speech_to_text(model_path, "CPU");
        speech_to_text.load_video(filename);
        std::cout << speech_to_text.transcribe(start_time, duration);
        speech_to_text.load_video("C:/data/legaleagle.mp4");
        std::cout << speech_to_text.transcribe(start_time, duration);
    }
    std::cout << std::endl;

    //std::cout << section.size() << std::endl;

    //auto audio = ffmpeg_get_audio();
    //run_whisper_model(audio);


    std::cout << std::endl << "Done" << std::endl;

    return 0;
}
