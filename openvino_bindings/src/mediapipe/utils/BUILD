licenses(["notice"])
load("@mediapipe//mediapipe/framework/port:build_config.bzl", "mediapipe_cc_proto_library", "mediapipe_proto_library")


package(default_visibility = ["//visibility:public"])

cc_library(
    name = "utils",
    deps = [
        "//src/image:data_structures",
        ":loop_calculators",
        ":crop_calculator",
        ":overlay_calculator",
        ":detection_extraction_calculator",
        ":combiner_calculators",
        ":emptylabel_calculators",
        "//src/image:contourer",
    ],
    alwayslink = 1,
)


cc_library(
    name = "detection_extraction_calculator",
    srcs = [
        "detection_extraction_calculator.cc",
    ],
    hdrs = [
        "detection_extraction_calculator.h",
    ],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "//src/image:data_structures",
        "//src/mediapipe/inference:geti_calculator_base",
        "//src/mediapipe/inference:inference_utils",
    ],
    alwayslink = 1,
)

cc_library(
    name = "loop_calculators",
    srcs = [
        "loop_calculators.cc",
    ],
    hdrs = [
        "loop_calculators.h",
    ],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/calculators/core:begin_loop_calculator",
        "@mediapipe//mediapipe/calculators/core:end_loop_calculator",
        "//src/image:data_structures",
        "//src/mediapipe/inference:geti_calculator_base",
        "//third_party:model_api",
    ],
    alwayslink = 1,
)

cc_library(
    name = "combiner_calculators",
    srcs = [
        "detection_classification_combiner_calculator.cc",
        "detection_classification_result_calculator.cc",
        "detection_segmentation_combiner_calculator.cc",
        "detection_segmentation_result_calculator.cc"
    ],
    hdrs = [
        "detection_classification_combiner_calculator.h",
        "detection_classification_result_calculator.h",
        "detection_segmentation_combiner_calculator.h",
        "detection_segmentation_result_calculator.h"
    ],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/formats:image_frame",
        "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
        "//src/image:data_structures",
        "//src/mediapipe/inference:geti_calculator_base",
        "//src/mediapipe/inference:inference_utils",
    ],
    alwayslink = 1
)

cc_library(
    name = "crop_calculator",
    srcs = [
        "crop_calculator.cc",
    ],
    hdrs = [
        "crop_calculator.h",
    ],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/formats:image",
        "@mediapipe//mediapipe/framework/formats:image_frame",
        "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
        "@mediapipe//mediapipe/framework/port:opencv_core",
        "//src/image:data_structures",
        "//src/mediapipe/inference:geti_calculator_base",
    ],
    alwayslink = 1,
)

proto_library(
    name = "overlay_calculator_proto",
    srcs = ["overlay_calculator.proto"],
    visibility = ["//visibility:public"],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_proto",

    ],
)

mediapipe_cc_proto_library(
    name = "overlay_calculator_cc_proto",
    srcs = ["overlay_calculator.proto"],
    cc_deps = ["@mediapipe//mediapipe/framework:calculator_cc_proto"],
    visibility = ["//visibility:public"],
    deps = [":overlay_calculator_proto"],
)


cc_library(
    name = "overlay_calculator",
    srcs = [
        "overlay_calculator.cc",
    ],
    hdrs = [
        "overlay_calculator.h",
    ],
    deps = [
        "//src/image:data_structures",
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/formats:image_frame",
        "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
        "@mediapipe//mediapipe/framework/port:opencv_core",
        "//third_party:model_api",
        "//src/mediapipe/inference:geti_calculator_base",
        "//src/image:overlay",
        ":overlay_calculator_cc_proto",
    ],
    alwayslink = 1,
)

proto_library(
    name = "emptylabel_proto",
    srcs = ["emptylabel.proto"],
    visibility = ["//visibility:public"],
    deps = [
        "@mediapipe//mediapipe/framework:calculator_proto",
    ],
)

mediapipe_cc_proto_library(
    name = "emptylabel_cc_proto",
    srcs = ["emptylabel.proto"],
    cc_deps = ["@mediapipe//mediapipe/framework:calculator_cc_proto"],
    visibility = ["//visibility:public"],
    deps = [":emptylabel_proto"],
)

cc_library(
    name = "emptylabel_calculators",
    srcs = [
        "emptylabel_calculator.cc",
    ],
    hdrs = [
        "emptylabel_calculator.h",
    ],
    deps = [
        "//src/image:data_structures",
        ":emptylabel_cc_proto",
        "@mediapipe//mediapipe/framework:calculator_framework",
        "@mediapipe//mediapipe/framework/formats:image_frame",
        "@mediapipe//mediapipe/framework/formats:image_frame_opencv",
        "@mediapipe//mediapipe/framework/port:opencv_core",
        "//third_party:model_api",
        "//src/mediapipe/inference:geti_calculator_base",
    ],
    alwayslink = 1,
)
