/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#pragma once

#include <openvino/runtime/tensor.hpp>
#include <filesystem>
#include <fstream>

namespace utils
{
    ov::Tensor load_image(const std::filesystem::path& image_path);
    std::vector<ov::Tensor> load_images(const std::vector<std::string> & input_paths);
}