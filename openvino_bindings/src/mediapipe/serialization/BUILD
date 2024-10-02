load("@mediapipe//mediapipe/framework/port:build_config.bzl", "mediapipe_cc_proto_library", "mediapipe_proto_library")

proto_library(
    name = "serialization_calculator_proto",
    srcs = ["serialization_calculator.proto"],
    visibility = ["//visibility:public"],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_proto",

    ],
)

mediapipe_cc_proto_library(
    name = "serialization_calculator_cc_proto",
    srcs = ["serialization_calculator.proto"],
    cc_deps = ["@mediapipe//mediapipe/framework:calculator_cc_proto"],
    visibility = ["//visibility:public"],
    deps = [":serialization_calculator_proto"],
)


cc_library(
    name = "calculators",
    hdrs = [
        "serialization_calculators.h",

    ],
    srcs = [
        "serialization_calculators.cc",

    ],
    deps = [
        ":serialization_calculator_cc_proto",
        "//src/image:serialization",
        "//src/mediapipe/inference:inference_calculators",
        "//src/mediapipe/inference:geti_calculator_base",
        "//src/mediapipe/inference:inference_utils",
    ],
    visibility = ["//visibility:public"],
    alwayslink=1
)
