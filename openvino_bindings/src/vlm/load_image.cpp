/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define STB_IMAGE_IMPLEMENTATION
#include "load_image.hpp"
#include <opencv2/opencv.hpp>

namespace fs = std::filesystem;

#include <filesystem>
#include <iostream>

std::vector<ov::Tensor> utils::load_images(const std::vector<std::string>& input_paths) {
    std::vector<ov::Tensor> images;
    images.reserve(input_paths.size());

    for (const std::string& dir_entry : input_paths) {
        std::filesystem::path image_path(dir_entry);
        if (!exists(image_path)) {
            std::cerr << "Warning: File does not exist - " << dir_entry << std::endl;
            continue; // Skip this file
        }
        images.push_back(load_image(image_path));
    }
    return images;
}

ov::Tensor utils::load_image(const std::filesystem::path& image_path) {
    constexpr int desired_channels = 3;

    // Load the image using OpenCV
    std::ifstream file(image_path, std::ios::binary);
    if (!file) {
        throw std::runtime_error{"Cannot access file."};
    }

    std::vector<uchar> buffer((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
    cv::Mat cv_image = cv::imdecode(buffer, cv::IMREAD_COLOR);
    cv::cvtColor(cv_image, cv_image, cv::COLOR_BGR2RGB);

    if (cv_image.empty()) {
        throw std::runtime_error{"Failed to load the image."};
    }

    // Ensure the image is converted to the desired number of channels
    if (cv_image.channels() != desired_channels) {
        throw std::runtime_error{"The loaded image does not have the desired number of channels."};
    }

    int width = cv_image.cols;
    int height = cv_image.rows;

    struct SharedImageAllocator {
        unsigned char* image;
        int channels, height, width;

        void* allocate(size_t bytes, size_t) const {
            if (image && static_cast<size_t>(channels * height * width) == bytes) {
                return image;
            }
            throw std::runtime_error{"Unexpected number of bytes was requested to allocate."};
        }

        void deallocate(void*, size_t bytes, size_t) {
            if (static_cast<size_t>(channels * height * width) != bytes) {
                throw std::runtime_error{"Unexpected number of bytes was requested to deallocate."};
            }
            image = nullptr; // Prevent dangling pointer
        }

        bool is_equal(const SharedImageAllocator& other) const noexcept {
            return this == &other;
        }
    };

    // Wrap OpenCV image data into the custom allocator
    return ov::Tensor(
        ov::element::u8,
        ov::Shape{1, static_cast<size_t>(height), static_cast<size_t>(width), static_cast<size_t>(desired_channels)},
        SharedImageAllocator{cv_image.data, desired_channels, height, width}
    );
}
