#ifndef SPEECH_TO_TEXT_H_
#define SPEECH_TO_TEXT_H_

#include <memory>
#include "openvino/genai/whisper_pipeline.hpp"
#include "audio_grabber.h"

class SpeechToText {
private:
    std::unique_ptr<AudioGrabber> audio_grabber;
    ov::genai::WhisperPipeline pipe;
    ov::genai::WhisperGenerationConfig config;
public:
    SpeechToText(std::string model_path, std::string device): pipe(model_path, device), config(model_path + "/generation_config.json") {}
    void load_video(std::string video_path);
    ov::genai::DecodedResults transcribe(int start, int duration);
};


#endif // SPEECH_TO_TEXT_H_
