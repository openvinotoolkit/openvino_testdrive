/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef AUDIO_GRABBER_H_
#define AUDIO_GRABBER_H_

#include <iostream>
#include <exception>
#include <vector>

extern "C"{
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswresample/swresample.h>
#include <libavutil/opt.h>
}

class AudioGrabber {
private:
    int audioStreamIndex = -1;
    AVFormatContext *formatContext = nullptr;
    AVCodecContext *codecContext = nullptr;
    SwrContext *swrContext = nullptr;
public:
    std::string filename;
    AudioGrabber(std::string filename);
    ~AudioGrabber();
    std::vector<float> grab_chunk(uint64_t start_time, uint64_t duration);
    int64_t get_duration();
};


#endif // AUDIO_GRABBER_H_
