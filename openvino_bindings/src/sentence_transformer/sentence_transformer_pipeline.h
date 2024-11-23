#ifndef SENTENCE_TRANSFORMER_PIPELINE_H_
#define SENTENCE_TRANSFORMER_PIPELINE_H_

#include <string>
#include <vector>
#include "openvino/openvino.hpp"


struct SentenceTransformerTokenizedInputs {
    ov::Tensor input_ids;
    ov::Tensor attention_mask;
    ov::Tensor token_type_ids;
};

class SentenceTransformerPipeline {
public:
    SentenceTransformerPipeline(std::string model_path, std::string device);
    std::vector<float> generate(std::string prompt);

    static float cosine_similarity(const std::vector<float>& vec1, const std::vector<float>& vec2);

private:
    std::vector<float> mean_pool(ov::Tensor tensor);

    SentenceTransformerTokenizedInputs generate_tokens(std::string prompt);

    void add_tokenizer(ov::Core& core);
    ov::CompiledModel tokenizer_model;
    ov::CompiledModel embedder_model;
};


#endif // SENTENCE_TRANSFORMER_PIPELINE_H_
