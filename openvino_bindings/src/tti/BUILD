cc_library(
    name = "tti_inference",
    srcs = [
        "tti_inference.cc",
    ],
    hdrs = [
        "tti_inference.h",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//src/image:serialization",
        "//src/utils",
        "//src/utils:errors",
        "//src/utils:tti_metrics",
        "//third_party:opencv",
        "//third_party:openvino",
        "@nlohmann_json//:json",
    ],
)

cc_test(
    name = "tti_inference_test",
    srcs = [
        "tti_inference_test.cc",
    ],
    data = [
        "//data:models",
    ],
    deps = [
        ":tti_inference",
        "@gtest//:gtest_main",
    ],
)
