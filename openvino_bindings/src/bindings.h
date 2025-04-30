/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifdef _WIN32
    #ifdef COMPILING_DLL
        #define EXPORT extern "C" __declspec(dllexport)
    #else
        #define EXPORT __declspec(dllimport)
    #endif
#else
    #define EXPORT
    #ifdef __cplusplus
        #define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
    #endif
#endif

#include <stddef.h>
#include <stdbool.h>
#include "src/utils/status.h"
#include "src/utils/metrics.h"
#include "utils/tti_metrics.h"
#include "utils/vlm_metrics.h"

typedef void* CImageInference;
typedef void* CGraphRunner;
typedef void* CSpeechToText;
typedef void* CLLMInference;
typedef void* CTTIInference;
typedef void* CSentenceTransformer;
typedef void* CVLMInference;

typedef struct {
    const char* id;
    const char* name;
} Device;

typedef struct {
    int width;
    int height;
} CameraResolution;

typedef struct {
    int id;
    const char* name;
    CameraResolution* resolutions;
    int size;
} CameraDevice;

typedef struct {
  float start_ts;
  float end_ts;
  const char* text;
} TranscriptionChunk;

typedef struct {
    enum StatusEnum status;
    const char* message;
} Status;

typedef struct {
    enum StatusEnum status;
    const char* message;
    const char* value;
} StatusOrString;

typedef struct {
    enum StatusEnum status;
    const char* message;
    bool value;
} StatusOrBool;

typedef struct {
    enum StatusEnum status;
    const char* message;
    int value;
} StatusOrInt;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CGraphRunner value;
} StatusOrGraphRunner;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CSentenceTransformer value;
} StatusOrSentenceTransformer;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CSpeechToText value;
} StatusOrSpeechToText;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CLLMInference value;
} StatusOrLLMInference;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CLLMInference value;
} StatusOrTTIInference;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CLLMInference value;
} StatusOrVLMInference;

typedef struct {
    enum StatusEnum status;
    const char* message;
    Metrics metrics;
    const char* value;
} StatusOrModelResponse;

typedef struct {
    enum StatusEnum status;
    const char* message;
    Metrics metrics;
    TranscriptionChunk* value;
    int size;
    const char* text;
} StatusOrWhisperModelResponse;

typedef struct {
    enum StatusEnum status;
    const char* message;
    TTIMetrics metrics;
    const char* value;
} StatusOrTTIModelResponse;

typedef struct {
    enum StatusEnum status;
    const char* message;
    float* value;
    int size;
} StatusOrEmbeddings;

typedef struct {
    enum StatusEnum status;
    const char* message;
    VLMMetrics metrics;
    const char* value;
} StatusOrVLMModelResponse;

typedef struct {
    enum StatusEnum status;
    const char* message;
    Device* value;
    int size;
} StatusOrDevices;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CameraDevice* value;
    int size;
} StatusOrCameraDevices;

typedef void (*ImageInferenceCallbackFunction)(StatusOrString*);
typedef void (*LLMInferenceCallbackFunction)(StatusOrString*);
typedef void (*VLMInferenceCallbackFunction)(StatusOrString*);

EXPORT void freeStatus(Status *status);
EXPORT void freeStatusOrString(StatusOrString *status);
EXPORT void freeStatusOrInt(StatusOrInt *status);
EXPORT void freeStatusOrLLMInference(StatusOrLLMInference *status);
EXPORT void freeStatusOrSpeechToText(StatusOrSpeechToText *status);
EXPORT void freeStatusOrModelResponse(StatusOrModelResponse *status);
EXPORT void freeStatusOrWhisperModelResponse(StatusOrWhisperModelResponse *status);
EXPORT void freeStatusOrDevices(StatusOrDevices *status);
EXPORT void freeStatusOrEmbeddings(StatusOrEmbeddings *status);
EXPORT void freeStatusOrCameraDevices(StatusOrCameraDevices *status);

EXPORT StatusOrLLMInference* llmInferenceOpen(const char* model_path, const char* device);
EXPORT Status* llmInferenceSetListener(CLLMInference instance, LLMInferenceCallbackFunction callback);
EXPORT StatusOrModelResponse* llmInferencePrompt(CLLMInference instance, const char* message, bool apply_template, float temperature, float top_p);
EXPORT Status* llmInferenceClearHistory(CLLMInference instance);
EXPORT Status* llmInferenceForceStop(CLLMInference instance);
EXPORT StatusOrString* llmInferenceGetTokenizerConfig(CLLMInference instance);
EXPORT Status* llmInferenceClose(CLLMInference instance);

EXPORT StatusOrTTIInference* ttiInferenceOpen(const char* model_path, const char* device);
EXPORT StatusOrTTIModelResponse* ttiInferencePrompt(CTTIInference instance, const char* message, int width, int height, int rounds);
EXPORT StatusOrBool* ttiInferenceHasModelIndex(CTTIInference instance);
EXPORT Status* ttiInferenceClose(CLLMInference instance);


EXPORT StatusOrVLMInference* vlmInferenceOpen(const char* model_path, const char* device);
EXPORT Status* vlmInferenceSetListener(CVLMInference instance, VLMInferenceCallbackFunction callback);
EXPORT StatusOrVLMModelResponse* vlmInferencePrompt(CVLMInference instance, const char* message, int max_new_tokens);
EXPORT Status* vlmInferenceSetImagePaths(CVLMInference instance, const char** paths, int length);
EXPORT StatusOrBool* vlmInferenceHasModelIndex(CVLMInference instance);
EXPORT Status* vlmInferenceStop(CVLMInference instance);
EXPORT Status* vlmInferenceClose(CVLMInference instance);

EXPORT StatusOrGraphRunner* graphRunnerOpen(const char* graph);
EXPORT Status* graphRunnerQueueImage(CGraphRunner instance, const char* name, int timestamp, unsigned char* image_data, const size_t data_length);
EXPORT Status* graphRunnerQueueSerializationOutput(CGraphRunner instance, const char* name, int timestamp, bool json, bool csv, bool overlay, bool source);
EXPORT StatusOrString* graphRunnerGet(CGraphRunner instance);
EXPORT Status* graphRunnerStop(CGraphRunner instance);
EXPORT Status* graphRunnerStartCamera(CGraphRunner instance, int cameraIndex, ImageInferenceCallbackFunction callback, bool json, bool csv, bool overlay, bool source);
EXPORT StatusOrInt* graphRunnerGetTimestamp(CGraphRunner instance);
EXPORT Status* graphRunnerStopCamera(CGraphRunner instance);
EXPORT Status* graphRunnerSetCameraResolution(CGraphRunner instance, int width, int height);


EXPORT StatusOrSentenceTransformer* sentenceTransformerOpen(const char* model_path, const char* device);
EXPORT StatusOrEmbeddings* sentenceTransformerGenerate(CSentenceTransformer instance, const char* prompt);
EXPORT Status* sentenceTransformerClose(CSentenceTransformer instance);

EXPORT StatusOrSpeechToText* speechToTextOpen(const char* model_path, const char* device);
EXPORT Status* speechToTextLoadVideo(CSpeechToText instance, const char* video_path);
EXPORT StatusOrInt* speechToTextVideoDuration(CSpeechToText instance);
EXPORT StatusOrWhisperModelResponse* speechToTextTranscribe(CSpeechToText instance, int start, int duration, const char* language);

EXPORT Status* ModelAPISerializeModel(const char* model_path, const char* output_path);
EXPORT StatusOrDevices* getAvailableDevices();
EXPORT StatusOrCameraDevices* getAvailableCameraDevices();

Status* handle_exceptions();

//extern "C" void report_rss();
