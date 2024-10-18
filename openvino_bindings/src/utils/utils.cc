#include "utils.h"


float nan_safe(const float& value) {
    if (std::isnan(value)) {
        return 0.0f;
    } else {
        return value;
    }
}


Metrics convertToMetricsStruct(ov::genai::PerfMetrics m) {
    return Metrics{
        nan_safe(m.get_load_time()),
        nan_safe(m.get_generate_duration().mean),
        nan_safe(m.get_tokenization_duration().mean),
        nan_safe(m.get_detokenization_duration().mean),
        nan_safe(m.get_ttft().mean),
        nan_safe(m.get_tpot().mean),
        nan_safe(m.get_throughput().mean),
        int(m.num_generated_tokens),
        int(m.num_input_tokens)
    };
}
