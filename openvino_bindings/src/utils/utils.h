#ifndef UTILS_UTILS_H_
#define UTILS_UTILS_H_

#include "openvino/genai/perf_metrics.hpp"
#include "metrics.h"
#include <cmath>

float nan_safe(const float& value);
Metrics convertToMetricsStruct(ov::genai::PerfMetrics m);


#endif // UTILS_H_
