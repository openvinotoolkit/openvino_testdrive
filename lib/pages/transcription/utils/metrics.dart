// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:inference/interop/generated_bindings.dart';

class DMetrics {
  double loadTime;
  double generateTime;
  double tokenizationTime;
  double detokenizationTime;
  double ttft;
  double tpot;
  double throughput;
  int numberOfGeneratedTokens;
  int numberOfInputTokens;

  int n = 1; // number of added metrics

  DMetrics({
    required this.loadTime,
    required this.generateTime,
    required this.tokenizationTime,
    required this.detokenizationTime,
    required this.ttft,
    required this.tpot,
    required this.throughput,
    required this.numberOfGeneratedTokens,
    required this.numberOfInputTokens,
  });

  void addCMetrics(Metrics metrics) {
    //loadTime = metrics.load_time;
    generateTime += metrics.generate_time;
    tokenizationTime += metrics.tokenization_time;
    detokenizationTime += metrics.detokenization_time;
    ttft = (ttft * (n / (n + 1))) + metrics.ttft / n;
    tpot = (tpot * (n / (n + 1))) + metrics.tpot / n;
    throughput = (throughput * (n / (n + 1))) + metrics.throughput / n;
    numberOfGeneratedTokens += metrics.number_of_generated_tokens;
    numberOfInputTokens += metrics.number_of_input_tokens;
    n += 1;
  }

  factory DMetrics.fromCMetrics(Metrics metrics) {
    return DMetrics(
      loadTime: metrics.load_time,
      generateTime: metrics.generate_time,
      tokenizationTime: metrics.tokenization_time,
      detokenizationTime: metrics.detokenization_time,
      ttft: metrics.ttft,
      tpot: metrics.tpot,
      throughput: metrics.throughput,
      numberOfGeneratedTokens: metrics.number_of_generated_tokens,
      numberOfInputTokens: metrics.number_of_input_tokens,
    );
  }
}
