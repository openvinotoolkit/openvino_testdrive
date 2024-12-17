// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

#include <future>
#include <fstream>
#include <sstream>

#include "gtest/gtest.h"
#include "src/utils/status.h"
#include "bindings.h"

TEST(Bindings, LLMInference) {
    std::string model_path = "data/TinyLlama-1.1B-Chat-v1.0-int4-ov";
    auto llm_inference_status = llmInferenceOpen(model_path.c_str(), "CPU");
    std::cout << llm_inference_status->message << std::endl;
    EXPECT_EQ(llm_inference_status->status, OkStatus);

    auto instance = llm_inference_status->value;
    auto result = llmInferencePrompt(instance, "What is the color of the sun?", 1.0f, 1.0f);
    EXPECT_EQ(result->status, OkStatus);
    EXPECT_STREQ(result->value, "The color of the sun is a beautiful and awe-inspiring yellow-amber color. It is a natural, radiant, and beautiful color that is associated with warmth, light, and lightning. The sun is often depicted as a radiant, yellow-amber ball of light that shines down on the earth, illuminating the world and inspiring wonder and awe in all who see it.");
    llmInferenceClose(instance);
}

std::vector<StatusOrString*> Bindings_LLMInferenceStreamerResult;

void Bindings_LLMInferenceStreamerCallback(StatusOrString* status) {
    Bindings_LLMInferenceStreamerResult.push_back(status);
}


TEST(Bindings, LLMInferenceStreamer) {
    std::string model_path = "data/TinyLlama-1.1B-Chat-v1.0-int4-ov";
    auto llm_inference_status = llmInferenceOpen(model_path.c_str(), "CPU");
    EXPECT_EQ(llm_inference_status->status, OkStatus);

    auto instance = llm_inference_status->value;
    llmInferenceSetListener(instance, Bindings_LLMInferenceStreamerCallback);
    auto result = llmInferencePrompt(instance, "What is the color of the sun?", 1.0f, 1.0f);
    EXPECT_EQ(result->status, OkStatus);
    EXPECT_STREQ(result->value, "The color of the sun is a beautiful and awe-inspiring yellow-amber color. It is a natural, radiant, and beautiful color that is associated with warmth, light, and lightning. The sun is often depicted as a radiant, yellow-amber ball of light that shines down on the earth, illuminating the world and inspiring wonder and awe in all who see it.");

    std::vector<std::string> expected_tokens = {
        "The", " color", " of", " the", " sun", " is", " a", " beautiful", " and",
        " a", "we", "-", "in", "sp", "iring", " yellow", "-", "am", "ber", " color",
        ".", " It", " is", " a", " natural", ",", " radi", "ant", ",", " and", " beautiful",
        " color", " that", " is", " associated", " with", " warm", "th", ",", " light", ",",
        " and", " light", "ning", ".", " The", " sun", " is", " often", " dep", "icted",
        " as", " a", " radi", "ant", ",", " yellow", "-", "am", "ber", " ball", " of",
        " light", " that", " sh", "ines", " down", " on", " the", " earth", ",", " ill",
        "umin", "ating", " the", " world", " and", " insp", "iring", " wonder", " and", " a",
        "we", " in", " all", " who", " see", " it", ".", ""
    };

    ASSERT_EQ(Bindings_LLMInferenceStreamerResult.size(), expected_tokens.size()) << "Vectors are of unequal length";

    for (int i = 0; i < Bindings_LLMInferenceStreamerResult.size(); i++) {
        EXPECT_EQ(Bindings_LLMInferenceStreamerResult[i]->value, expected_tokens[i]);
        freeStatusOrString(Bindings_LLMInferenceStreamerResult[i]);
    }

    llmInferenceClose(instance);
}
