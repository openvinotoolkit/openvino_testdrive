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

typedef void* CImageInference;
typedef void* CGraphRunner;
typedef void* CSpeechToText;
typedef void* CLLMInference;

typedef struct {
    const char* id;
    const char* name;
} Device;


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
    CImageInference value;
} StatusOrImageInference;

typedef struct {
    enum StatusEnum status;
    const char* message;
    CGraphRunner value;
} StatusOrGraphRunner;

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
    Metrics metrics;
    const char* value;
} StatusOrModelResponse;

typedef struct {
    enum StatusEnum status;
    const char* message;
    Device* value;
    int size;
} StatusOrDevices;

typedef void (*ImageInferenceCallbackFunction)(StatusOrString*);
typedef void (*LLMInferenceCallbackFunction)(StatusOrString*);

EXPORT void freeStatus(Status *status);
EXPORT void freeStatusOrString(StatusOrString *status);
EXPORT void freeStatusOrImageInference(StatusOrImageInference *status);
EXPORT void freeStatusOrLLMInference(StatusOrLLMInference *status);
EXPORT void freeStatusOrSpeechToText(StatusOrSpeechToText *status);
EXPORT void freeStatusOrDevices(StatusOrDevices *status);

EXPORT StatusOrImageInference* imageInferenceOpen(const char* model_path, const char* task, const char* device, const char* label_definitions_json);
EXPORT StatusOrString* imageInferenceInfer(CImageInference instance, unsigned char* image_data, const size_t data_length, bool json, bool csv, bool overlay);
EXPORT StatusOrString* imageInferenceInferRoi(CImageInference instance, unsigned char* image_data, const size_t data_length, int x, int y, int width, int height, bool json, bool csv, bool overlay);
EXPORT Status* imageInferenceInferAsync(CImageInference instance, const char* id, unsigned char* image_data, const size_t data_length, bool json, bool csv, bool overlay);
EXPORT Status* imageInferenceSetListener(CImageInference instance, ImageInferenceCallbackFunction callback);
EXPORT Status* imageInferenceOpenCamera(CImageInference instance, int device);
EXPORT Status* imageInferenceStopCamera(CImageInference instance);
EXPORT Status* imageInferenceClose(CImageInference instance);
EXPORT Status* imageInferenceSerializeModel(const char* model_path, const char* output_path);
EXPORT Status* load_font(const char* font_path);

EXPORT StatusOrLLMInference* llmInferenceOpen(const char* model_path, const char* device);
EXPORT Status* llmInferenceSetListener(CLLMInference instance, LLMInferenceCallbackFunction callback);
EXPORT StatusOrModelResponse* llmInferencePrompt(CLLMInference instance, const char* message, float temperature, float top_p);
EXPORT Status* llmInferenceClearHistory(CLLMInference instance);
EXPORT Status* llmInferenceForceStop(CLLMInference instance);
EXPORT StatusOrBool* llmInferenceHasChatTemplate(CLLMInference instance);
EXPORT Status* llmInferenceClose(CLLMInference instance);

EXPORT StatusOrGraphRunner* graphRunnerOpen(const char* graph);
EXPORT Status* graphRunnerQueueImage(CGraphRunner instance, const char* name, int timestamp, unsigned char* image_data, const size_t data_length);
EXPORT Status* graphRunnerQueueSerializationOutput(CGraphRunner instance, const char* name, int timestamp, bool json, bool csv, bool overlay);
EXPORT StatusOrString* graphRunnerGet(CGraphRunner instance);
EXPORT Status* graphRunnerStop(CGraphRunner instance);

EXPORT StatusOrSpeechToText* speechToTextOpen(const char* model_path, const char* device);
EXPORT Status* speechToTextLoadVideo(CSpeechToText instance, const char* video_path);
EXPORT StatusOrInt* speechToTextVideoDuration(CSpeechToText instance);
EXPORT StatusOrModelResponse* speechToTextTranscribe(CSpeechToText instance, int start, int duration, const char* language);

EXPORT StatusOrDevices* getAvailableDevices();
Status* handle_exceptions();

//extern "C" void report_rss();
