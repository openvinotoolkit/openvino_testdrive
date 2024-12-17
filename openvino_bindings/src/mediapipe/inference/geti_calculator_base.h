/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef GETI_CALCULATOR_BASE_H
#define GETI_CALCULATOR_BASE_H

#include <iostream>

#include "mediapipe/framework/calculator_framework.h"

namespace mediapipe {

class GetiCalculatorBase : public CalculatorBase {
 public:
  absl::Status Open(CalculatorContext* cc) override {
    try {
      return GetiOpen(cc);
    } catch (const std::exception& e) {
      LOG(ERROR) << "Caught exception with message: " << e.what();
      return mediapipe::UnknownError(e.what());
    } catch (...) {
      LOG(ERROR) << "Caught unknown exception";
      return mediapipe::UnknownError("Caught unknown exception");
    }
  }

  absl::Status Process(CalculatorContext* cc) override {
    try {
      return GetiProcess(cc);
    } catch (const std::exception& e) {
      std::cout << "Caught exception with message: " << e.what() << std::endl;
      return mediapipe::UnknownError(e.what());
    } catch (...) {
      std::cout << "Caught unknown exception" << std::endl;
      return mediapipe::UnknownError("Caught unknown exception");
    }
  }
  virtual absl::Status GetiOpen(CalculatorContext* cc) = 0;
  virtual absl::Status GetiProcess(CalculatorContext* cc) = 0;
};

}  // namespace mediapipe

#endif  // GETI_CALCULATOR_BASE_H
