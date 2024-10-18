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
    ]
)

cc_library(
    name = "metrics",
    hdrs = [
        "metrics.h"
    ],
)

cc_library(
    name = "utils",
    hdrs = [
        "utils.h"
    ],
    srcs = [
        "utils.cc"
    ],
    deps = [
        "//third_party:openvino",
        ":metrics",
    ],
)
