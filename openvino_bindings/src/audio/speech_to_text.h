/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef SPEECH_TO_TEXT_H_
#define SPEECH_TO_TEXT_H_


#include <memory>
#include "openvino/genai/whisper_pipeline.hpp"
#include "audio_grabber.h"

class SpeechToText {
private:
    std::unique_ptr<AudioGrabber> audio_grabber;
    ov::genai::WhisperPipeline pipe;
public:
    SpeechToText(std::string model_path, std::string device): pipe(model_path, device) {}
    void load_video(std::string video_path);
    int64_t video_duration();
    ov::genai::WhisperDecodedResults transcribe(int start, int duration, std::string language);
};


#endif // SPEECH_TO_TEXT_H_
