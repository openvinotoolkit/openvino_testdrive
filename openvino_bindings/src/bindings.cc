/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "bindings.h"
#include <iostream>
#include <opencv2/opencv.hpp>
#include <nlohmann/json.hpp>
#include <openvino/openvino.hpp>

#include "src/audio/speech_to_text.h"
#include "src/image/image_inference.h"
#include "src/mediapipe/graph_runner.h"
#include "src/mediapipe/serialization/serialization_calculators.h"
#include "src/llm/llm_inference.h"
#include "src/tti/tti_inference.h"
#include "src/vlm/vlm_inference.h"
#include "src/utils/errors.h"
#include "src/utils/utils.h"
#include "src/utils/input_devices.h"
#include "src/utils/status.h"
#include "src/image/json_serialization.h"
#include "src/image/csv_serialization.h"
#include "src/image/overlay.h"

void freeStatus(Status *status) {
    //std::cout << "Freeing Status" << std::endl;
    delete status;
}

void freeStatusOrString(StatusOrString *status) {
    //std::cout << "Freeing StatusOrString" << std::endl;
    if (status->status == StatusEnum::OkStatus) {
        free((void*)status->value);  // Free the allocated memory
        status->value = NULL;        // Prevent dangling pointers
    }
    delete status;
}

void freeStatusOrInt(StatusOrInt *status) {
    delete status;
}

//void freeStatusOrSpeechToText(StatusOrSpeechToText *status) {
//    delete status;
//}

void freeStatusOrImageInference(StatusOrString *status) {
    //std::cout << "Freeing StatusOrImageInference" << std::endl;
    delete status;
}

void freeStatusOrModelResponse(StatusOrModelResponse *status) {
    //std::cout << "Freeing StatusOrImageInference" << std::endl;
    delete status;
}

void freeStatusOrWhisperModelResponse(StatusOrWhisperModelResponse *status) {
    if (status->status == StatusEnum::OkStatus) {
        delete [] status->value;
        status->value = NULL;        // Prevent dangling pointers
    }
    delete status;
}

void freeStatusOrDevices(StatusOrDevices *status) {
    if (status->status == StatusEnum::OkStatus) {
        delete [] status->value;
        status->value = NULL;        // Prevent dangling pointers
    }
    delete status;
}

void freeStatusOrDevices(StatusOrCameraDevices *status) {
    if (status->status == StatusEnum::OkStatus) {
        delete [] status->value;
        status->value = NULL;        // Prevent dangling pointers
    }
    delete status;
}


StatusOrImageInference* imageInferenceOpen(const char* model_path, const char* task, const char* device, const char* label_definitions_json) {
    try {
        auto instance = new ImageInference(model_path, get_task_type(task), device);
        instance->project_labels = nlohmann::json::parse(label_definitions_json);
        return new StatusOrImageInference{OkStatus, "", instance};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrImageInference{except->status, except->message};
    }
}

Status* imageInferenceClose(CImageInference instance) {
    auto inference = reinterpret_cast<ImageInference*>(instance);
    inference->close();
    delete inference;
    return new Status{OkStatus};
}

StatusOrString* imageInferenceInfer(CImageInference instance, unsigned char* image_data, const size_t data_length, bool json, bool csv, bool overlay) {
    try {
        if(!(json || csv || overlay)){
            return new StatusOrString{OverlayNoOutputSelected};
        }
        auto image_inference = reinterpret_cast<ImageInference*>(instance);
        std::vector<char> image_vector(image_data, image_data + data_length);
        auto image = cv::imdecode(image_vector, 1);
        auto inference_result = image_inference->infer(image);
        auto result = image_inference->serialize(inference_result, image, json, csv, overlay).dump();
        return new StatusOrString{OkStatus, "", strdup(result.c_str())};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrString{except->status, except->message};
    }
}

StatusOrString* imageInferenceInferRoi(CImageInference instance, unsigned char* image_data, const size_t data_length, int x, int y, int width, int height, bool json, bool csv, bool overlay) {
    try {
        if(!(json || csv || overlay)){
            return new StatusOrString{OverlayNoOutputSelected};
        }

        auto image_inference = reinterpret_cast<ImageInference*>(instance);
        std::vector<char> image_vector(image_data, image_data + data_length);
        auto image = cv::imdecode(image_vector, 1);
        cv::cvtColor(image, image, cv::COLOR_BGR2RGB);
        auto rect = cv::Rect(x, y, width, height);
        auto roi = image(rect).clone();
        auto inference_result = image_inference->infer(roi);
        auto result = image_inference->serialize(inference_result, roi, json, csv, overlay).dump();
        return new StatusOrString{OkStatus, "", strdup(result.c_str())};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrString{except->status, except->message};
    }
}

Status* imageInferenceInferAsync(CImageInference instance, const char* id, unsigned char* image_data, const size_t data_length, bool json, bool csv, bool overlay) {
    try {
        auto image_inference = reinterpret_cast<ImageInference*>(instance);
        std::vector<char> image_vector(image_data, image_data + data_length);
        auto image = cv::imdecode(image_vector, 1);
        image_inference->inferAsync(image, id, json, csv, overlay);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* imageInferenceSetListener(CImageInference instance, ImageInferenceCallbackFunction callback) {
    try {
        auto lambda_callback = [callback](StatusEnum status, const std::string& error_message, const std::string& response) {
            callback(new StatusOrString{status, strdup(error_message.c_str()), strdup(response.c_str())});
        };
        auto image_inference = reinterpret_cast<ImageInference*>(instance);
        image_inference->set_listener(lambda_callback);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* imageInferenceSerializeModel(const char* model_path, const char* output_path) {
    try {
        ImageInference::serialize_model(model_path, output_path);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* imageInferenceOpenCamera(CImageInference instance, int device) {
    try {
        auto image_inference = reinterpret_cast<ImageInference*>(instance);
        image_inference->open_camera(device);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* imageInferenceStopCamera(CImageInference instance) {
    try {
        auto image_inference = reinterpret_cast<ImageInference*>(instance);
        image_inference->stop_camera();
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* load_font(const char* font_path) {
    try {
        ImageInference::load_font(font_path);
        return new Status{OkStatus};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrLLMInference* llmInferenceOpen(const char* model_path, const char* device) {
    try {
        auto instance = new LLMInference(model_path, device);
        return new StatusOrLLMInference{OkStatus, "", instance};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrLLMInference{except->status, except->message};
    }
}

Status* llmInferenceSetListener(CLLMInference instance, LLMInferenceCallbackFunction callback) {
    try {
        auto lambda_callback = [callback](const std::string& word) {
            callback(new StatusOrString{OkStatus, "", strdup(word.c_str())});
        };
        reinterpret_cast<LLMInference*>(instance)->set_streamer(lambda_callback);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrModelResponse* llmInferencePrompt(CLLMInference instance, const char* message, float temperature, float top_p) {
    try {
        auto inference = reinterpret_cast<LLMInference*>(instance);
        auto result = inference->prompt(message, temperature, top_p);
        std::string text = result;
        return new StatusOrModelResponse{OkStatus, "", convertToMetricsStruct(result.perf_metrics), strdup(text.c_str())};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrModelResponse{except->status, except->message, {}};
    }
}

Status* llmInferenceClearHistory(CLLMInference instance) {
    try {
        reinterpret_cast<LLMInference*>(instance)->clear_history();
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrBool* llmInferenceHasChatTemplate(CLLMInference instance) {
    try {
        bool has_chat_template = reinterpret_cast<LLMInference*>(instance)->has_chat_template();
        return new StatusOrBool{OkStatus, "", has_chat_template};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrBool{except->status, except->message};
    }
}

Status* llmInferenceForceStop(CLLMInference instance) {
    try {
        reinterpret_cast<LLMInference*>(instance)->force_stop();
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* llmInferenceClose(CLLMInference instance) {
    auto inference = reinterpret_cast<LLMInference*>(instance);
    //inference->stop();
    delete inference;
    return new Status{OkStatus};
}


StatusOrTTIInference* ttiInferenceOpen(const char* model_path, const char* device) {
    try {
        auto instance = new TTIInference(model_path, device);
        return new StatusOrTTIInference{OkStatus, "", instance};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrTTIInference{except->status, except->message};
    }
}

StatusOrTTIModelResponse* ttiInferencePrompt(CTTIInference instance, const char* message, int width, int height, int rounds) {
    try {
        auto inference = reinterpret_cast<TTIInference*>(instance);
        auto result = inference->prompt(message, width, height, rounds);
        auto text = result.string;
        auto metrics = result.metrics;
        return new StatusOrTTIModelResponse{OkStatus, {}, metrics, text};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrTTIModelResponse{except->status, except->message, {}, {}};
    }
}

StatusOrBool* ttiInferenceHasModelIndex(CTTIInference instance) {
    try {
        bool has_chat_template = reinterpret_cast<TTIInference*>(instance)->has_model_index();
        return new StatusOrBool{OkStatus, "", has_chat_template};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrBool{except->status, except->message};
    }
}

Status* ttiInferenceClose(CTTIInference instance) {
    auto inference = reinterpret_cast<TTIInference*>(instance);
    inference->stop();
    delete inference;
    return new Status{OkStatus};
}

StatusOrVLMInference* vlmInferenceOpen(const char* model_path, const char* device) {
    try {
        auto instance = new VLMInference(model_path, device);
        return new StatusOrVLMInference{OkStatus, "", instance};
    } catch (...) {
        auto except = handle_exceptions();
        printf(except->message);
        return new StatusOrVLMInference{except->status, except->message};
    }
}

Status* vlmInferenceSetListener(CVLMInference instance, VLMInferenceCallbackFunction callback) {
    try {
        auto lambda_callback = [callback](const std::string& word) {
            callback(new StatusOrString{OkStatus, "", strdup(word.c_str())});
        };
        reinterpret_cast<VLMInference*>(instance)->set_streamer(lambda_callback);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrVLMModelResponse* vlmInferencePrompt(CVLMInference instance, const char* message, int max_new_tokens) {
    try {
        auto inference = reinterpret_cast<VLMInference*>(instance);
        auto result = inference->prompt(message, max_new_tokens);
        auto text = result.string;
        auto metrics = result.metrics;
        return new StatusOrVLMModelResponse{OkStatus, {}, metrics, text};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrVLMModelResponse{except->status, except->message, {}, {}};
    }
}

Status* vlmInferenceSetImagePaths(CVLMInference instance, const char** paths, int length) {
    try {
        auto inference = reinterpret_cast<VLMInference*>(instance);

        std::vector<std::string> stringPaths;
        stringPaths.reserve(length);
        for (int i = 0; i < length; ++i) {
            stringPaths.emplace_back(paths[i]);
        }

        inference->setImagePaths(stringPaths);
        return new Status{OkStatus};
    } catch (...) {
        return new Status{ErrorStatus};
    }
}

StatusOrBool* vlmInferenceHasModelIndex(CVLMInference instance) {
    try {
        bool has_chat_template = reinterpret_cast<VLMInference*>(instance)->has_model_index();
        return new StatusOrBool{OkStatus, "", has_chat_template};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrBool{except->status, except->message};
    }
}

Status* vlmInferenceForceStop(CVLMInference instance) {
    try {
        reinterpret_cast<VLMInference*>(instance)->force_stop();
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* vlmInferenceClose(CVLMInference instance) {
    auto inference = reinterpret_cast<VLMInference*>(instance);
    inference->force_stop();
    delete inference;
    return new Status{OkStatus};
}


StatusOrGraphRunner* graphRunnerOpen(const char* graph) {
    try {
        auto instance = new GraphRunner();
        instance->open_graph(graph);
        return new StatusOrGraphRunner{OkStatus, "", instance};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrGraphRunner{except->status, except->message};
    }

}

Status* graphRunnerQueueImage(CGraphRunner instance, const char* name, int timestamp, unsigned char* image_data, const size_t data_length) {
    try {
        std::vector<char> image_vector(image_data, image_data + data_length);
        auto image = cv::imdecode(image_vector, 1);
        cv::cvtColor(image, image, cv::COLOR_BGR2RGB);
        reinterpret_cast<GraphRunner*>(instance)->queue(name, timestamp, image);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* graphRunnerQueueSerializationOutput(CGraphRunner instance, const char* name, int timestamp, bool json, bool csv, bool overlay) {
    try {
        reinterpret_cast<GraphRunner*>(instance)->queue(name, timestamp, SerializationOutput{json, csv, overlay});
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

Status* graphRunnerStartCamera(CGraphRunner instance, int camera_index, ImageInferenceCallbackFunction callback, bool json, bool csv, bool overlay) {
    try {
        auto runner = reinterpret_cast<GraphRunner*>(instance);

        auto lambda_callback = [callback](std::string response) {
            callback(new StatusOrString{OkStatus, "", strdup(response.c_str())});
        };
        runner->open_camera(camera_index, SerializationOutput{json, csv, overlay}, lambda_callback);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrInt* graphRunnerGetTimestamp(CGraphRunner instance) {
    try {
        auto graph_runner = reinterpret_cast<GraphRunner*>(instance);
        return new StatusOrInt{OkStatus, "", (int)graph_runner->timestamp};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrInt{except->status, except->message};
    }
}

Status* graphRunnerStopCamera(CGraphRunner instance) {
    try {
        reinterpret_cast<GraphRunner*>(instance)->stop_camera();
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrString* graphRunnerGet(CGraphRunner instance) {
    try {
        auto graph_runner = reinterpret_cast<GraphRunner*>(instance);
        auto result = graph_runner->get();
        return new StatusOrString{OkStatus, "", strdup(result.c_str())};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrString{except->status, except->message};
    }
}

Status* graphRunnerStop(CGraphRunner instance) {
    try {
        auto graph_runner = reinterpret_cast<GraphRunner*>(instance);
        graph_runner->stop();
        delete graph_runner;
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrSpeechToText* speechToTextOpen(const char* model_path, const char* device) {
    try {
        auto instance = new SpeechToText(model_path, device);
        return new StatusOrSpeechToText{OkStatus, "", instance};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrSpeechToText{except->status, except->message};
    }
}

Status* speechToTextLoadVideo(CSpeechToText instance, const char* video_path) {
    try {
        auto object = reinterpret_cast<SpeechToText*>(instance);
        object->load_video(video_path);
        return new Status{OkStatus, ""};
    } catch (...) {
        return handle_exceptions();
    }
}

StatusOrInt* speechToTextVideoDuration(CSpeechToText instance) {
    try {
        auto object = reinterpret_cast<SpeechToText*>(instance);
        object->video_duration();
        // Deal with long in the future
        return new StatusOrInt{OkStatus, "", (int)object->video_duration()};
    } catch (...) {
        return new StatusOrInt{OkStatus, ""};
    }
}

StatusOrWhisperModelResponse* speechToTextTranscribe(CSpeechToText instance, int start, int duration, const char* language) {
    try {
        auto object = reinterpret_cast<SpeechToText*>(instance);
        auto transcription_result = object->transcribe(start, duration, language);
        auto chunks = transcription_result.chunks.value();
        std::string text = transcription_result;
        TranscriptionChunk* result = new TranscriptionChunk[chunks.size()];
        for (int i = 0; i < chunks.size(); i++) {
            auto r = chunks[i];
            result[i] = TranscriptionChunk{r.start_ts + start, r.end_ts + start, strdup(r.text.c_str())};
        }
        return new StatusOrWhisperModelResponse{OkStatus, "", convertToMetricsStruct(transcription_result.perf_metrics), result, (int)chunks.size(), strdup(text.c_str())};
    } catch (...) {
        auto except = handle_exceptions();
        return new StatusOrWhisperModelResponse{except->status, except->message};
    }
}

//void report_rss() {
//    struct rusage r_usage;
//    getrusage(RUSAGE_SELF, &r_usage);
//    std::cout << "RSS: " << r_usage.ru_maxrss  << std::endl;
//}

StatusOrDevices* getAvailableDevices() {
    auto core = ov::Core();
    auto device_ids = core.get_available_devices();
    Device* devices = new Device[device_ids.size() + 1];
    devices[0] = {"AUTO", "auto"};
    for (int i = 0; i < device_ids.size(); i++) {
        auto device_name = core.get_property(device_ids[i], ov::device::full_name);
        devices[i + 1] = { strdup(device_ids[i].c_str()), strdup(device_name.c_str()) };
    }

    return new StatusOrDevices{OkStatus, "", devices, (int)device_ids.size() + 1};
}

StatusOrCameraDevices* getAvailableCameraDevices() {
    auto cameras = list_camera_devices();
    CameraDevice* devices = new CameraDevice[cameras.size()];
    int i = 0;
    for (auto camera: cameras) {
        devices[i] = { (int)camera.first, strdup(camera.second.c_str()) };
        i++;
    }

    return new StatusOrCameraDevices{OkStatus, "", devices, (int)cameras.size()};
}

Status* handle_exceptions() {
    try {
        throw;
    } catch(ov::Exception e) {
        std::string message = "OV Exception: \n";
        message += e.what();
        std::cout << message << std::endl;
        return new Status{OpenVINOError, strdup(message.c_str())};
    } catch (api_error e) {
        std::cout << "api error: " << e.what() << std::endl;
        return new Status{e.status, strdup(e.additional_info.c_str())};
    } catch(const std::exception& ex) {
        std::cout << "std::exception: " << ex.what() << std::endl;
        return new Status{ErrorStatus, ex.what()};
    } catch (...) {
        std::cout << "Unknown exception" << std::endl;
        return new Status{ErrorStatus, "Unknown exception"};
    }
}
