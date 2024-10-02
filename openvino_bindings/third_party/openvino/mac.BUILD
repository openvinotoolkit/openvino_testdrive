package(
    default_visibility = ["//visibility:public"],
)

filegroup(
    name = "shared_objects",
    srcs = glob([
        "lib/arm64/Release/**/*.so",
        "3rdparty/tbb/lib/libtbb.12.dylib",
    ])
)

cc_library(
    name = "ngraph",
    hdrs = glob([
        "include/ngraph/**/*.*"
    ]),
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "openvino_new_headers",
    hdrs = glob([
        "include/openvino/**/*.*"
    ]),
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "openvino",
    hdrs = glob([
        "include/openvino/**/*"
    ]),
    srcs = glob([
        "lib/arm64/Release/**/*.dylib",
    ]),
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
    data = [
        ":shared_objects",
    ],
    deps = [
        "@openvino_mac//:ngraph",
        "@openvino_mac//:openvino_new_headers",
    ],
)
