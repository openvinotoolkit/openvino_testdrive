/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef VLM_METRICS_H
#define VLM_METRICS_H

typedef struct {
    float load_time;
    float generate_time;
    const float tokenization_time;
    const float detokenization_time;
    const float ttft;
    const float tpot;
    const float throughput;
    const int number_of_generated_tokens;
    const int number_of_input_tokens;
} VLMMetrics;

typedef struct {
    const char* string;
    VLMMetrics metrics;
} VLMStringWithMetrics;

#endif //VLM_METRICS_H
