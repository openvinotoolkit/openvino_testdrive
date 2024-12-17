// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

enum HintsEnum { intelCoreLLMPerformanceSuggestion }

class Hints {
  late Map<HintsEnum, bool> hints;
  Hints() {
    hints = { for (var v in HintsEnum.values) v : true };
  }
}

class Config {
  static bool geti = false;
  static Hints hints = Hints();
  static bool proxyDirect = false;
}
