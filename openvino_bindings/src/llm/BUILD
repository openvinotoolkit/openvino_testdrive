cc_library(
    name = "llm_inference",
    hdrs = [
        "llm_inference.h",
    ],
    srcs = [
        "llm_inference.cc",
    ],
    deps = [
        "@nlohmann_json//:json",
         "//third_party:openvino",
         "//src/utils:errors",
         ":metrics",
    ],
    visibility = ["//visibility:public"],
)

cc_test(
    name = "llm_inference_test",
    deps = [
        "@gtest//:gtest_main",
        ":llm_inference",
    ],
    srcs = [
        "llm_inference_test.cc",
    ],
    data = [
        "//data:models",
    ]
)

cc_library(
    name = "metrics",
    hdrs =  [
        "metrics.h"
    ],
    visibility = ["//visibility:public"],
)
