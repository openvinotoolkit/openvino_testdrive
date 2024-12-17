/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "gtest/gtest.h"
#include "llm_inference.h"

TEST(LLMInference, Sanity) {
    std::string model_path = "data/TinyLlama-1.1B-Chat-v1.0-int4-ov";
    LLMInference inference(model_path, "CPU");
    std::string output = inference.prompt("What is the color of the sun?", 1.0f, 1.0f);
    EXPECT_STREQ(output.c_str(), "The color of the sun is a beautiful and awe-inspiring yellow-amber color. It is a natural, radiant, and beautiful color that is associated with warmth, light, and lightning. The sun is often depicted as a radiant, yellow-amber ball of light that shines down on the earth, illuminating the world and inspiring wonder and awe in all who see it.");
}
