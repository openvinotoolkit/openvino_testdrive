package(default_visibility = ["//visibility:public"])

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
        "//third_party:openvino",
    ],
)
