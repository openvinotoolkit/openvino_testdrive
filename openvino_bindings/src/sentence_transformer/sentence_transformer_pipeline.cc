/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "sentence_transformer_pipeline.h"

SentenceTransformerPipeline::SentenceTransformerPipeline(std::string model_path, std::string device) {
    ov::Core core;
    add_tokenizer(core);

    std::string tokenizer_path = model_path + "/openvino_tokenizer.xml";
    std::string embedder_path = model_path + "/openvino_model.xml";

    tokenizer_model = core.compile_model(tokenizer_path, device);
    embedder_model = core.compile_model(embedder_path, device);
}

std::vector<float> SentenceTransformerPipeline::generate(std::string prompt) {
    auto tokenized = generate_tokens(prompt);

    auto infer_request = embedder_model.create_infer_request();

    infer_request.set_tensor("input_ids", tokenized.input_ids);
    infer_request.set_tensor("attention_mask", tokenized.attention_mask);
    infer_request.set_tensor("token_type_ids", tokenized.token_type_ids);
    infer_request.infer();
    auto result = infer_request.get_output_tensor(0);
    return mean_pool(result);
}

SentenceTransformerTokenizedInputs SentenceTransformerPipeline::generate_tokens(std::string prompt) {
    auto infer_request = tokenizer_model.create_infer_request();
    size_t batch_size = 1;
    infer_request.set_input_tensor(0, ov::Tensor{ov::element::string, {batch_size}, &prompt});
    infer_request.infer();
    auto input_ids = infer_request.get_output_tensor(0);
    auto attention_mask = infer_request.get_output_tensor(1);
    auto token_type_ids = infer_request.get_output_tensor(2);
    return {input_ids, attention_mask, token_type_ids};
}

void SentenceTransformerPipeline::add_tokenizer(ov::Core& core) {
    #ifdef defined(WIN32)
        core.add_extension("openvino_tokenizers.dll");
    #elif __APPLE__
        core.add_extension("libopenvino_tokenizers.dylib");
    #elif __linux__
        core.add_extension("libopenvino_tokenizers.so");
    #endif
}

std::vector<float> SentenceTransformerPipeline::mean_pool(ov::Tensor tensor) {
    auto shape = tensor.get_shape();
    float* output_data = tensor.data<float>();

    size_t batch_size = shape[0];
    size_t num_tokens = shape[1];
    size_t hidden_size = shape[2];

    std::vector<float> sentence_embedding(hidden_size, 0.0f);

    for (size_t token = 0; token < num_tokens; ++token) {
        for (size_t dim = 0; dim < hidden_size; ++dim) {
            sentence_embedding[dim] += output_data[token * hidden_size + dim];
        }
    }

    for (size_t dim = 0; dim < hidden_size; ++dim) {
        sentence_embedding[dim] /= static_cast<float>(num_tokens);
    }

    return sentence_embedding;
}

float SentenceTransformerPipeline::cosine_similarity(const std::vector<float>& vec1, const std::vector<float>& vec2) {
    if (vec1.size() != vec2.size()) {
        throw std::invalid_argument("Vectors must be of the same size");
    }

    float dotProduct = 0.0f;
    float normVec1 = 0.0f;
    float normVec2 = 0.0f;

    for (size_t i = 0; i < vec1.size(); ++i) {
        dotProduct += vec1[i] * vec2[i];
        normVec1 += vec1[i] * vec1[i];
        normVec2 += vec2[i] * vec2[i];
    }

    if (normVec1 == 0 || normVec2 == 0) {
        throw std::invalid_argument("Vectors must not be zero-vectors");
    }

    return dotProduct / (std::sqrt(normVec1) * std::sqrt(normVec2));
}
