#ifndef SENTENCE_EXTRACTOR_H_
#define SENTENCE_EXTRACTOR_H_

#include <string>

namespace sentence_extractor {
    std::string extract_text_from_pdf(const std::string& path);
}


#endif // SENTENCE_EXTRACTOR_H_
