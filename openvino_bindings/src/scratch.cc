#include <iostream>

#include "src/pdf/sentence_extractor.h"


int main(int argc, char** argv) {
  std::string input = argv[1];

  auto sentences = sentence_extractor::extract_sentences_from_pdf(input);
  for (auto &sentence: sentences) {
    std::cout << sentence << std::endl;
  }


  std::cout << "done" << std::endl;
  return 0;
}
