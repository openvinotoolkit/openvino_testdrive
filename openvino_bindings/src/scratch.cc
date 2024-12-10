
#include <iostream>
#include "src/audio/speech_to_text.h"

int main() {
  auto path = "/Users/rhecker/data/genai/whisper-base";
  SpeechToText model(path, "CPU");
  model.load_video("/Users/rhecker/Downloads/HEA! Kroegbaas Jolke [6K-F6q-VurY].mp4");
  std::cout << model.transcribe(40, 10, "<|en|>") << std::endl;
  std::cout << model.transcribe(40, 10, "<|en|>") << std::endl;
  std::cout << model.transcribe(40, 10, "") << std::endl;
  //std::cout << model.transcribe(40, 10, "") << std::endl;
  //std::cout << model.transcribe(40, 10, "<|en|>") << std::endl;
}
