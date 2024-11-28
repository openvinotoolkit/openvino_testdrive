#ifndef SENTENCE_EXTRACTOR_H_
#define SENTENCE_EXTRACTOR_H_

#include <vector>

namespace sentence_extractor {
    std::string clean_text(const std::string& raw_text);
    std::vector<std::string> tokenize_sentences(const std::string& text);
    std::vector<std::string> extract_sentences_from_pdf(const std::string& path);
    std::string extract_text_from_pdf(const std::string& path);
}


#endif // SENTENCE_EXTRACTOR_H_
