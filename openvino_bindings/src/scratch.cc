//#include "src/sentence_transformer/sentence_transformer_pipeline.h"
#include <iostream>
#include "src/sentence_transformer/sentence_transformer_pipeline.h"


int main() {
  std::string model_path = "/Users/rhecker/data/genai/all-MiniLM-L6-v2/fp16";

  SentenceTransformerPipeline pipeline(model_path, "CPU");
  auto vec1 =  pipeline.generate("Obama speaks to the media in Illinois");
  auto vec2 =  pipeline.generate("Obama speaks to the media in Chicago");

  std::cout << SentenceTransformerPipeline::cosine_similarity(vec1, vec2);
}
