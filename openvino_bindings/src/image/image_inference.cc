/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include <adapters/openvino_adapter.h>
#include <models/detection_model.h>
#include <models/classification_model.h>
#include <models/instance_segmentation.h>
#include <models/segmentation_model.h>
#include <models/anomaly_model.h>
#include <models/input_data.h>
#include <stdexcept>
#include <thread>

#include "image_inference.h"
#include "src/image/csv_serialization.h"
#include "src/image/json_serialization.h"
#include "src/image/post_processing.h"
#include "src/image/utils.h"
#include "src/utils/errors.h"
#include "src/utils/status.h"
#include "third_party/cpp-base64/base64.h"


ModelType get_model_type(const std::string& name) {
    if (name == "ssd" || name == "Detection") {
        return ModelType::Detection;
    } else if (name == "Classification") {
        return ModelType::Classification;
    } else if (name == "MaskRCNN") {
        return ModelType::MaskRCNN;
    } else if (name == "Segmentation") {
        return ModelType::Segmentation;
    } else if (name == "AnomalyDetection") {
        return ModelType::Anomaly;
    } else {
        throw api_error(ModelTypeNotSupported, name);
    }
}

TaskType get_task_type(const std::string& name) {
    if (name == "detection") {
        return TaskType::Detection;
    } else if (name == "classification") {
        return TaskType::Classification;
    } else if (name == "rotated_detection") {
        return TaskType::RotatedDetection;
    } else if (name == "instance_segmentation") {
        return TaskType::InstanceSegmentation;
    } else if (name == "segmentation") {
        return TaskType::Segmentation;
    } else if (name == "anomaly") {
        return TaskType::Anomaly;
    } else if (name == "anomaly_classification") {
        return TaskType::Anomaly;
    } else {
        throw api_error(TaskTypeNotSupported, name);
    }
}


inline void output_model_config(std::shared_ptr<InferenceAdapter> ia) {
    auto config = ia->getModelConfig();
    for (auto& prop: config) {
        std::cout << prop.first << ": " << prop.second.as<std::string>()  << std::endl;
    }
}

BLFontFace ImageInference::face;

ImageInference::ImageInference(std::string model_path, TaskType task, std::string device): task(task) {
    auto core = ov::Core();
    auto ov_model = core.read_model(model_path);
    ia = std::make_shared<OpenVINOInferenceAdapter>();
    ov::AnyMap tput{{ov::hint::performance_mode.name(), ov::hint::PerformanceMode::THROUGHPUT}};
    ia->loadModel(ov_model, core, device, tput);
    auto config = ia->getModelConfig();

    labels = geti::get_labels_from_configuration(config);

    auto model_type_iter = config.find("model_type");
    if (model_type_iter == config.end()) {
        throw api_error(StatusEnum::ModelTypeNotSupplied);
    }
    model_type = get_model_type(model_type_iter->second.as<std::string>());

    switch(model_type) {
        case ModelType::Detection:
            model = DetectionModel::create_model(ia);
            break;
        case ModelType::Classification:
            model = ClassificationModel::create_model(ia);
            break;
        case ModelType::MaskRCNN:
            {
                auto maskrcnn = MaskRCNNModel::create_model(model_path, {}, true, device);
                // post processing for rotated detection via model api
                maskrcnn->postprocess_semantic_masks = task == TaskType::RotatedDetection;
                model = std::unique_ptr<ImageModel>(maskrcnn.release());
            }
            break;
        case ModelType::Segmentation:
            model = SegmentationModel::create_model(ia);
            //model->postprocess_semantic_masks = false;
            break;
        case ModelType::Anomaly:
            model = AnomalyModel::create_model(ia);
            break;
        default:
            throw std::runtime_error("Model type loading not implemented");
    }
}

geti::InferenceResult ImageInference::infer(cv::Mat image) {
    const ImageInputData& input_data = image;

    geti::InferenceResult obj = post_process(model->infer(input_data), image);
    if (empty_label.has_value()) {
        size_t n_predictions = obj.polygons.size() +
                            obj.rectangles.size() +
                            obj.circles.size() +
                            obj.rotated_rectangles.size();

        if (n_predictions == 0) {
            obj.rectangles.push_back({{geti::LabelResult{0.0f, empty_label.value()}}, obj.roi});
        }
    }
    return obj;
}

geti::InferenceResult ImageInference::post_process(std::unique_ptr<ResultBase> result, cv::Mat image) {
    switch(task) {
        case TaskType::Detection:
            return geti::detection_post_processing(std::move(result), labels, image);
        case TaskType::Classification:
            return geti::classification_post_processing(std::move(result), labels, image);
        case TaskType::RotatedDetection:
            return geti::rotated_detection_post_processing(std::move(result), labels, image);
        case TaskType::Anomaly:
            return geti::anomaly_post_processing(std::move(result), labels, image);
        case TaskType::InstanceSegmentation:
            return geti::instance_segmentation_post_processing(std::move(result), labels, image);
        case TaskType::Segmentation:
            auto m = dynamic_cast<SegmentationModel*>(model.get());
            auto inference_result = std::unique_ptr<ImageResultWithSoftPrediction>(static_cast<ImageResultWithSoftPrediction*>(result.release()));
            auto contours = m->getContours(*inference_result.get()); //uhh..
            return geti::segmentation_post_processing(std::move(inference_result), contours, labels, image);
    }
    throw std::runtime_error("Model type loading not implemented");
}

void ImageInference::inferAsync(cv::Mat image, const std::string& id, bool json, bool csv, bool overlay) {
    const ImageInputData& input_data = image;
    model->inferAsync(input_data, {{"image", image}, {"id", id}, {"json", json}, {"csv", csv}, {"overlay", overlay}});
}


void ImageInference::set_listener(const std::function<void(StatusEnum status, const std::string& error_message, const std::string& response)> callback) {
    auto lambda_callback = [callback, this](std::unique_ptr<ResultBase> result, const ov::AnyMap& args) {
        try {
            cv::Mat image = args.find("image")->second.as<cv::Mat>();
            bool csv = args.find("csv")->second.as<bool>();
            bool json = args.find("json")->second.as<bool>();
            bool overlay = args.find("overlay")->second.as<bool>();
            auto inference_result = post_process(std::move(result), image);
            auto response = serialize(inference_result, image, json, csv, overlay);
            response["id"] = args.find("id")->second.as<std::string>();
            callback(OkStatus, "", response.dump());
        } catch(const api_error& re) {
            callback(re.status, re.additional_info, "");
        } catch(const std::exception& ex) {
            callback(ErrorStatus, strdup(ex.what()), "");
        } catch (...) {
            callback(ErrorStatus, "", "");
        }
    };
    model->setCallback(lambda_callback);
}

nlohmann::json ImageInference::serialize(const geti::InferenceResult& inference_result, cv::Mat image, bool json, bool csv, bool overlay) {
    nlohmann::json output = {};
    if (json) {
        output["json"] = inference_result;
    }
    if (csv) {
        output["csv"] = geti::csv_serialize(inference_result);
    }
    if (overlay) {
        auto overlay = geti::draw_overlay(image, inference_result, draw_options, project_labels, ImageInference::face);
        cv::Mat overlay_rgb;
        cv::cvtColor(overlay, overlay_rgb, cv::COLOR_RGB2BGRA);
        output["overlay"] = geti::base64_encode_mat(overlay_rgb);
    }

    return output;
}

void ImageInference::close() {
    //nothing to clean up yet...
    stop_camera();
}

bool ImageInference::model_loaded() {
    return model != nullptr;
}

void ImageInference::open_camera(int device) {
    camera_get_frame = true;
    camera_thread = std::thread(&ImageInference::start_camera, this, device);
}

void ImageInference::stop_camera() {
    camera_get_frame = false;
    if (camera_thread.joinable()) {
        camera_thread.join();
    }
}

void ImageInference::start_camera(int device) {
    cv::VideoCapture cap;
    std::cout << device << std::endl;
    cap.open(device);
    if (!cap.isOpened()) {
        throw api_error(CameraNotOpenend);
    }

    cv::Mat frame;
    int i = 0;
    while(camera_get_frame) {
        std::cout << "input..." << std::endl;
        cap.read(frame);
        std::cout << frame.rows << std::endl;
        if (frame.empty()) {
            std::cout << "empty frame" << std::endl;
            continue;
        }
        inferAsync(frame, "frame_" + std::to_string(i), false, false, true);
        model->awaitAll();
        i++;
    }
}

 void ImageInference::load_font(const char* font_path) {
    auto font_success = ImageInference::face.createFromFile(font_path);
    if (font_success != BL_SUCCESS) {
        throw api_error(FontLoadError);
    }

}

void ImageInference::serialize_model(const std::string& model_path, const std::string& output_path) {
    std::unique_ptr<ModelBase> model;
    std::string device = "CPU"; //Loading is faster on CPU, and serialization is a small task

    std::string model_type = "";
    {
        auto core = ov::Core();
        auto ov_model = core.read_model(model_path);

        auto config = ov_model->get_rt_info<ov::AnyMap>("model_info");
        auto model_type_iter = config.find("model_type");
        if (model_type_iter == config.end()) {
            throw api_error(StatusEnum::ModelTypeNotSupplied);
        }
        model_type = model_type_iter->second.as<std::string>();
    }

    switch(get_model_type(model_type)) {
        case ModelType::Detection:
            model = DetectionModel::create_model(model_path, {}, "", true, device);
            break;
        case ModelType::Classification:
            model = ClassificationModel::create_model(model_path, {}, true, device);
            break;
        case ModelType::Segmentation:
            model = SegmentationModel::create_model(model_path, {}, true, device);
            break;
        case ModelType::MaskRCNN:
            model = MaskRCNNModel::create_model(model_path, {}, true, device);
            break;
        case ModelType::Anomaly:
            model = AnomalyModel::create_model(model_path, {}, true, device);
            break;
        default:
            throw std::runtime_error("Model type serialization not implemented");
    }
    ov::serialize(model->getModel(), output_path);
}
