/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "sentence_extractor.h"

#include <sstream>
#include <podofo/podofo.h>

namespace sentence_extractor {

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
