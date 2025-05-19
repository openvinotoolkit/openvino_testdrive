/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "utils.h"
#include "models/base_model.h"
#include <adapters/openvino_adapter.h>
#include <models/detection_model.h>
#include <models/classification_model.h>
#include <models/instance_segmentation.h>
#include <models/segmentation_model.h>
#include <models/anomaly_model.h>
#include <models/input_data.h>

namespace geti {

std::vector<geti::Label> get_labels_from_configuration(
    ov::AnyMap configuration) {
  auto labels_iter = configuration.find("labels");
  auto label_ids_iter = configuration.find("label_ids");
  std::vector<geti::Label> labels = {};
  if (labels_iter != configuration.end() &&
      label_ids_iter != configuration.end()) {
    std::vector<std::string> label_ids =
        label_ids_iter->second.as<std::vector<std::string>>();
    std::vector<std::string> label_names =
        labels_iter->second.as<std::vector<std::string>>();
    for (size_t i = 0; i < label_ids.size(); i++) {
      if (label_names.size() > i)
        labels.push_back({label_ids[i], label_names[i]});
      else
        labels.push_back({label_ids[i], ""});
    }
  }
  return labels;
}

BLRgba32 hex_to_color(std::string color) {
  std::stringstream ss;
  color.erase(0, 1);
  unsigned int x = std::stoul("0x" + color, nullptr, 16);
  auto output = BLRgba32(
    x >> 8 | (x & 0x000000FF) << 24
  );

  auto b = output.r();
  output.setR(output.b());
  output.setB(b);
  return output;

}

const ProjectLabel &get_label_by_id(const std::string &id,
                             const std::vector<ProjectLabel> &label_definitions) {
  for (const auto &label : label_definitions) {
    if (label.id == id) {
      return label;
    }
  }
  throw api_error(OverlayLabelNotFound, id);
}

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


void serialize_model(const std::string& model_path, const std::string& output_path) {
    std::unique_ptr<BaseModel> model;
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


}
