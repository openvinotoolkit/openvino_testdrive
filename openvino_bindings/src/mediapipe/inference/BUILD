load("@mediapipe//mediapipe/framework/port:build_config.bzl", "mediapipe_cc_proto_library", "mediapipe_proto_library")
load("@rules_cc//cc:defs.bzl", "cc_proto_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "openvino_inference_adapter_calculator_proto",
    srcs = ["openvino_inference_adapter_calculator.proto"],
    visibility = ["//visibility:public"],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_proto",

    ],
)

mediapipe_cc_proto_library(
    name = "openvino_inference_adapter_calculator_cc_proto",
    srcs = ["openvino_inference_adapter_calculator.proto"],
    cc_deps = ["@mediapipe//mediapipe/framework:calculator_cc_proto"],
    visibility = ["//visibility:public"],
    deps = [":openvino_inference_adapter_calculator_proto"],
)

cc_library(
    name = "inference_calculators",
    visibility = [
        "//visibility:public",
    ],
    srcs = [
        "anomaly_calculator.cc",
        "classification_calculator.cc",
        "detection_calculator.cc",
        "instance_segmentation_calculator.cc",
        "openvino_inference_adapter_calculator.cc",
        "rotated_detection_calculator.cc",
        "segmentation_calculator.cc",
    ],
    hdrs = [
        "anomaly_calculator.h",
        "classification_calculator.h",
        "detection_calculator.h",
        "instance_segmentation_calculator.h",
        "openvino_inference_adapter_calculator.h",
        "rotated_detection_calculator.h",
        "segmentation_calculator.h",
    ],
    deps = [
        ":openvino_inference_adapter_calculator_cc_proto",
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
        "@mediapipe//mediapipe/framework/port:opencv_core",
        "@mediapipe//mediapipe/framework/port:opencv_imgcodecs",
        "@mediapipe//mediapipe/framework/port:opencv_imgproc",
        "//src/mediapipe/utils:utils",
        ":inference_utils",
        "//third_party:model_api",
        ":geti_calculator_base",
    ],
    defines = [
        "USE_MODELADAPTER",
    ],
    alwayslink = 1,
)

cc_library(
    name = "inference_utils",
    srcs = ["utils.cc"],
    hdrs = ["utils.h"],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "//src/image:data_structures",
        "//third_party:model_api",
    ]
)

cc_library(
    name = "geti_calculator_base",
    hdrs = [
        "geti_calculator_base.h",
    ],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
    ],
    visibility = [
        "//visibility:public",
    ],
)
