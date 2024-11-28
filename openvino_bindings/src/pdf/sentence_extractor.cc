#include "sentence_extractor.h"

#include <regex>
#include <sstream>
#include <podofo/podofo.h>

namespace sentence_extractor {
std::string clean_text(const std::string& raw_text) {
    // Remove unnecessary line breaks but preserve paragraph structure
    std::string cleaned_text = std::regex_replace(raw_text, std::regex("-\\s*\n"), ""); // Remove hyphenated line breaks
    cleaned_text = std::regex_replace(cleaned_text, std::regex("\\n+"), "\n");         // Collapse multiple newlines
    cleaned_text = std::regex_replace(cleaned_text, std::regex("\\s{2,}"), " ");       // Remove extra spaces
    return cleaned_text;
}

std::vector<std::string> tokenize_sentences(const std::string& text) {
    std::vector<std::string> sentences;
    std::regex sentence_regex(R"(([^.!?]+[.!?]))");
    auto begin = std::sregex_iterator(text.begin(), text.end(), sentence_regex);
    auto end = std::sregex_iterator();

    for (auto i = begin; i != end; ++i) {
        sentences.push_back((*i).str());
    }
    return sentences;
}



std::vector<std::string> extract_sentences_from_pdf(const std::string& path) {
  PoDoFo::PdfMemDocument doc;
  doc.Load(path);
  auto& pages = doc.GetPages();
  std::vector<std::string> sentences = {};
  for (unsigned i = 0; i < pages.GetCount(); i++)
  {
      std::ostringstream rawText;
      auto& page = pages.GetPageAt(i);

      std::vector<PoDoFo::PdfTextEntry> entries;
      page.ExtractTextTo(entries);

      for (auto& entry : entries) {
        rawText << entry.Text.data() << " ";
      }
      auto cleaned = clean_text(rawText.str());
      auto tokenized = tokenize_sentences(cleaned);
      sentences.insert(sentences.end(), tokenized.begin(), tokenized.end());
  }

  return sentences;
}

std::string extract_text_from_pdf(const std::string& path) {
  PoDoFo::PdfMemDocument doc;
  doc.Load(path);
  auto& pages = doc.GetPages();
  std::string content;
  for (unsigned i = 0; i < pages.GetCount(); i++)
  {
      std::ostringstream rawText;
      auto& page = pages.GetPageAt(i);

      std::vector<PoDoFo::PdfTextEntry> entries;
      page.ExtractTextTo(entries);

      for (auto& entry : entries) {
        rawText << entry.Text.data() << " ";
      }
      content += rawText.str();
  }
  return content;
}
}
