/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef METRICS_H_
#define METRICS_H_

typedef struct {
    const float load_time;
    const float generate_time;
    const float tokenization_time;
    const float detokenization_time;
    const float ttft;
    const float tpot;
    const float throughput;
    const int number_of_generated_tokens;
    const int number_of_input_tokens;
} Metrics;



#endif // METRICS_H_
