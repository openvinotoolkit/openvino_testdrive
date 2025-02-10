package(default_visibility = ["//visibility:public"])

cc_library(
    name = "json_utils",
    hdrs = [
        "json_utils.h",
    ],
    deps = [
        "@nlohmann_json//:json",
    ]
)

cc_library(
    name = "camera_handler",
    hdrs = [
        "camera_handler.h",
    ],
    srcs = [
         "camera_handler.cc",
    ],
    deps = [
        "//third_party:opencv",
        ":errors",
    ],
)

cc_library(
    name = "errors",
    hdrs = [
        "errors.h",
    ],
    deps = [
        ":status",
    ],
)

cc_library(
    name = "status",
    hdrs = [
        "status.h",
    ],
)

cc_library(
    name = "input_devices",
    hdrs = ["input_devices.h"],
    deps = [
         ":errors",
    ],
    linkopts = select({
        "@platforms//os:windows": ["mfplat.lib", "mf.lib", "mfuuid.lib", "ole32.lib"],
        "@platforms//os:linux": [],  # No extra libraries needed for V4L2
        "@platforms//os:macos": ["-framework AVFoundation", "-framework Foundation"],
    }),
)

cc_library(
    name = "metrics",
    hdrs = [
        "metrics.h",
    ],
)

cc_library(
    name = "tti_metrics",
    hdrs = [
        "tti_metrics.h",
    ],
)

cc_library(
    name = "vlm_metrics",
    hdrs = [
        "vlm_metrics.h",
    ],
)

cc_library(
    name = "utils",
    srcs = [
        "utils.cc",
    ],
    hdrs = [
        "utils.h",
    ],
    deps = [
        ":metrics",
        ":tti_metrics",
        ":vlm_metrics",
        "//third_party:openvino",
    ],
)
