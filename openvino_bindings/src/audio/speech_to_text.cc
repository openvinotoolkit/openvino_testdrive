#include "speech_to_text.h"

#include "src/utils/errors.h"
#include "src/utils/status.h"


void SpeechToText::load_video(std::string video_path) {
    audio_grabber = std::make_unique<AudioGrabber>(video_path);
}

ov::genai::WhisperDecodedResults SpeechToText::transcribe(int start, int duration, std::string language) {
    auto video_duration = audio_grabber->get_duration();
    if (start > video_duration) {
        throw api_error(SpeechToTextChunkOutOfBounds);
    }
    if (start + duration > video_duration) {
        duration = video_duration - start;
    }
    if (!audio_grabber) {
        throw api_error(SpeechToTextFileNotOpened);
    }
    auto data = audio_grabber->grab_chunk(start, duration);
    if (data.empty()) {
        throw api_error(SpeechToTextChunkHasNoData);
    }
    if (language.empty()) {
        config.language.reset();
    } else {
        config.language = language;
    }
    config.return_timestamps = true;
    config.max_new_tokens = 100;
    return pipe.generate(data, config);
}


int64_t SpeechToText::video_duration() {
    if (!audio_grabber) {
        throw api_error(SpeechToTextFileNotOpened);
    }
    return audio_grabber->get_duration();
}
