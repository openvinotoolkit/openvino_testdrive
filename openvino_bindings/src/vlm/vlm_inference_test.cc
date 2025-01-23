/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "gtest/gtest.h"
#include "vlm_inference.h"

TEST(VLMInference, Sanity) {
    std::string model_path = std::filesystem::absolute("data/OpenGVLab-InternVL2-4B-ov-fp16");
    VLMInference inference(model_path, "CPU");
    inference.setImagePaths({ std::filesystem::absolute("data/images/cat-in-box.jpg")});
    VLMStringWithMetrics output = inference.prompt("what do you see", 200);
    EXPECT_STREQ(output.string, "In the image, there is a cat lying comfortably inside a cardboard box. The cat appears to be relaxed and content, with its eyes closed and a peaceful expression on its face. The box is placed on a carpeted floor, and in the background, there is a white sofa or couch. The overall setting suggests a cozy and homely environment.");
}
