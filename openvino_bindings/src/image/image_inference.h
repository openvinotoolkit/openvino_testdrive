#ifndef IMAGE_INFERENCE_H_
#define IMAGE_INFERENCE_H_

#include <memory>
#include <thread>
#include <string>
#include <optional>
#include <models/image_model.h>
#include <adapters/openvino_adapter.h>
#include <opencv2/opencv.hpp>
#include <nlohmann/json.hpp>

#include "data_structures.h"
#include "src/image/overlay.h"
#include "src/utils/status.h"


enum class ModelType {
  Detection,
  Classification,
  MaskRCNN,
  Segmentation,
  Anomaly,
};

ModelType get_model_type(const std::string& name);

enum class TaskType {
  Detection,
  Classification,
  RotatedDetection,
  InstanceSegmentation,
  Segmentation,
  Anomaly,
};

TaskType get_task_type(const std::string& name);

class ImageInference {
public:
    std::optional<geti::Label> empty_label;
    TaskType task;
    std::vector<geti::ProjectLabel> project_labels; // Labels with color coding etc.
    static BLFontFace face;

    ImageInference(std::string model_path, TaskType task, std::string device);

    bool model_loaded();
    geti::InferenceResult infer(cv::Mat image);
    void inferAsync(cv::Mat image, const std::string& id, bool json, bool csv, bool overlay);
    geti::InferenceResult post_process(std::unique_ptr<ResultBase> result, cv::Mat image);
    void set_listener(const std::function<void(StatusEnum status, const std::string& error_message, const std::string& response)> callback);
    nlohmann::json serialize(const geti::InferenceResult& inference_result, cv::Mat image, bool json, bool csv, bool overlay);

    void open_camera(int device);
    void stop_camera();
    bool camera_get_frame = false;

    static void load_font(const char* font_path);
    static void serialize_model(const std::string& model_path, const std::string& output_path);

    void close();
private:
    void start_camera(int device);

    ModelType model_type;
    std::shared_ptr<InferenceAdapter> ia;
    std::unique_ptr<ImageModel> model;
    std::vector<geti::Label> labels;
    geti::DrawOptions draw_options{2, 0.4, 1.0};
    std::thread camera_thread;

};


#endif // IMAGE_INFERENCE_H_
