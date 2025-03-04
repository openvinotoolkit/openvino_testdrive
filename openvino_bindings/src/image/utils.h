/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef IMAGE_UTILS_H_
#define IMAGE_UTILS_H_

#include "src/utils/errors.h"
#include "data_structures.h"
#include <blend2d.h>

namespace geti {

std::vector<geti::Label> get_labels_from_configuration(ov::AnyMap configuration);

BLRgba32 hex_to_color(std::string color);

const ProjectLabel &get_label_by_id(const std::string &id, const std::vector<ProjectLabel> &label_definitions);

void serialize_model(const std::string& model_path, const std::string& output_path);

enum class ModelType {
  Detection,
  Classification,
  MaskRCNN,
  Segmentation,
  Anomaly,
};

ModelType get_model_type(const std::string& name);

}

#endif // UTILS_H_
