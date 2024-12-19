/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef TTI_METRICS_H
#define TTI_METRICS_H

typedef struct {
    float load_time;
    float generate_time;
} TTIMetrics;

typedef struct {
    const char* string;
    TTIMetrics metrics;
} StringWithMetrics;

#endif //TTI_METRICS_H
