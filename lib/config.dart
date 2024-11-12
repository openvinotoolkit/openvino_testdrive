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
