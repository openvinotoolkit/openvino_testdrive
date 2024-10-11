#include "speech_to_text.h"

#include "src/utils/errors.h"
#include "src/utils/status.h"


void SpeechToText::load_video(std::string video_path) {
    audio_grabber = std::make_unique<AudioGrabber>(video_path);
}

std::string SpeechToText::transcribe(int start, int duration) {
    if (!audio_grabber) {
        throw api_error(SpeechToTextFileNotOpened);
    }
    auto data = audio_grabber->grab_chunk(start, duration);
    if (data.empty()) {
        throw api_error(SpeechToTextChunkHasNoData);
    }
    config.max_new_tokens = 100;
    return pipe.generate(data, config);
}
