#include "audio_grabber.h"

AudioGrabber::AudioGrabber(std::string filename): filename(filename) {
    // Has been removed
    // v_register_all(); //maybe move
    // Open video file
    if (avformat_open_input(&formatContext, filename.c_str(), nullptr, nullptr) != 0) {
        throw std::runtime_error("Failed to open video file!");
    }
    std::cout << "Opened " << filename << std::endl;

    if (avformat_find_stream_info(formatContext, nullptr) < 0) {
        avformat_close_input(&formatContext);
        throw std::runtime_error("Failed to find stream info!");
    }

    std::cout << "found stream info "<<std::endl;

    AVCodec *codec = nullptr;
    for (unsigned int i = 0; i < formatContext->nb_streams; i++) {
        if (formatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            audioStreamIndex = i;
            codec = const_cast<AVCodec*>(avcodec_find_decoder(formatContext->streams[i]->codecpar->codec_id));
            break;
        }
    }

    if (audioStreamIndex == -1 || !codec) {
        std::cerr << "Audio stream not found!" << std::endl;
        avformat_close_input(&formatContext);
        throw std::runtime_error("Audio stream not found!");
    }

    std::cout << "Found audio stream" << std::endl;

    codecContext = avcodec_alloc_context3(codec);
    avcodec_parameters_to_context(codecContext, formatContext->streams[audioStreamIndex]->codecpar);
    avcodec_open2(codecContext, codec, nullptr);

    swrContext = swr_alloc();
    av_opt_set_int(swrContext, "in_channel_layout", codecContext->channel_layout, 0);
    av_opt_set_int(swrContext, "in_sample_rate", codecContext->sample_rate, 0);
    av_opt_set_sample_fmt(swrContext, "in_sample_fmt", codecContext->sample_fmt, 0);

    av_opt_set_int(swrContext, "out_channel_layout", AV_CH_LAYOUT_MONO, 0);  // Mono output
    av_opt_set_int(swrContext, "out_sample_rate", 16000, 0);  // 16kHz output sample rate
    av_opt_set_sample_fmt(swrContext, "out_sample_fmt", AV_SAMPLE_FMT_S16, 0);  // 16-bit PCM output

    if (swr_init(swrContext) < 0) {
        throw std::runtime_error("Failed to initialize resampler!");
    }
    std::cout << "Done init" << std::endl;
}

AudioGrabber::~AudioGrabber() {
    avcodec_close(codecContext);
    avformat_close_input(&formatContext);
    swr_free(&swrContext);
}

std::vector<float> AudioGrabber::grab_chunk(uint64_t start_time, uint64_t duration) {
    AVFrame *frame = av_frame_alloc();
    AVPacket packet;
    std::vector<float> resampledAudio;  // For storing resampled audio data as float
    // Seek to the starting time (start_time in seconds)
    std::cout << "time base: " << formatContext->streams[audioStreamIndex]->time_base.den << std::endl;
    int64_t startPts = av_rescale_q(start_time * AV_TIME_BASE, AV_TIME_BASE_Q, formatContext->streams[audioStreamIndex]->time_base);
    std::cout << "startPts" << startPts << std::endl;
    av_seek_frame(formatContext, audioStreamIndex, startPts, AVSEEK_FLAG_ANY);

    int audioDurationPts = av_rescale_q(duration * AV_TIME_BASE, AV_TIME_BASE_Q, formatContext->streams[audioStreamIndex]->time_base);
    std::cout << "audioDurationPts: " << audioDurationPts << std::endl;
    int decoded = 0;
    while (av_read_frame(formatContext, &packet) >= 0 && decoded < audioDurationPts) {
        if (packet.stream_index == audioStreamIndex) {
            if (avcodec_send_packet(codecContext, &packet) >= 0) {
                while (avcodec_receive_frame(codecContext, frame) >= 0) {
                    // Resample the audio to 16kHz
                    int outSamples = swr_get_out_samples(swrContext, frame->nb_samples);
                    std::vector<uint8_t> buffer(outSamples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16));
                    uint8_t *outBuffer[] = { buffer.data() };

                    int resampledSamples = swr_convert(swrContext, outBuffer, outSamples,
                                                    (const uint8_t**)frame->data, frame->nb_samples);

                    int16_t *resampledData = reinterpret_cast<int16_t*>(buffer.data());

                    // Convert resampled int16_t samples to float and store in resampledAudio
                    for (int i = 0; i < resampledSamples; i++) {
                        float sample = resampledData[i] / 32768.0f;  // Convert to float in range [-1.0, 1.0]
                        resampledAudio.push_back(sample);
                    }
                }
            }
            decoded += packet.duration;
        }
        av_packet_unref(&packet);
    }
    av_frame_free(&frame);
    return resampledAudio;
}
