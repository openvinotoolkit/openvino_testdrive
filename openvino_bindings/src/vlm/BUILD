cc_library(
    name = "vlm_inference",
    srcs = [
        "load_image.cpp",
        "vlm_inference.cc",
    ],
    hdrs = [
        "load_image.hpp",
        "vlm_inference.h",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//src/image:serialization",
        "//src/utils",
        "//src/utils:errors",
        "//src/utils:vlm_metrics",
        "//third_party:opencv",
        "//third_party:openvino",
        "@nlohmann_json//:json",
    ],
)

cc_test(
    name = "vlm_inference_test",
    srcs = [
        "vlm_inference_test.cc",
    ],
    data = [
        "//data:models",
    ],
    deps = [
        ":vlm_inference",
        "@gtest//:gtest_main",
    ],
)
