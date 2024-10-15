#include <iostream>
#include <fstream>

#include "src/audio/speech_to_text.h"

int main(){
    std::cout << "Scratch" << std::endl;

    std::string model_path = "/data/genai/whisper-base";
    std::string filename = "/data/intel_test_video.mp4";
    int start_time = 0;
    int duration = 10;

    float lastTime = 0;

    SpeechToText speech_to_text(model_path, "CPU");
    speech_to_text.load_video(filename);
    for (start_time; start_time < 500; start_time += duration){
        auto result = speech_to_text.transcribe(start_time, duration, "");
        for (auto& chunk : *result.chunks) {
            bool brokenSentence = chunk.text.at(0) == ' ';
            if (!brokenSentence && lastTime + 0.01 < chunk.start_ts + start_time) {
                std::cout << std::endl; //paragraph
            }
            std::cout << "timestamps: [" << chunk.start_ts + start_time << ", " << chunk.end_ts + start_time << "] text: " << chunk.text << "\n";
            lastTime = chunk.end_ts + start_time;
        }
    }

    return 0;
}
