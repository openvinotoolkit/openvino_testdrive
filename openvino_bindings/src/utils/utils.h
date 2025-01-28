/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef UTILS_UTILS_H_
#define UTILS_UTILS_H_

#include "openvino/genai/perf_metrics.hpp"
#include "metrics.h"
#include "vlm_metrics.h"
#include <cmath>

float nan_safe(const float& value);
Metrics convertToMetricsStruct(ov::genai::PerfMetrics m);
VLMMetrics convertToVLMMetricsStruct(ov::genai::PerfMetrics m);


#endif // UTILS_H_
