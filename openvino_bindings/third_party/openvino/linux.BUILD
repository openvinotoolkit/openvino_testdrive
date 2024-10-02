package(
    default_visibility = ["//visibility:public"],
)

filegroup(
    name = "shared_objects",
    srcs = glob([
        "lib/**/*.so",
    ])
)

cc_library(
    name = "openvino_old_headers",
    hdrs = glob([
        "include/ie/**/*.*"
    ]),
    strip_include_prefix = "include/ie",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "openvino_new_headers",
    hdrs = glob([
        "include/openvino/**/*.*"
    ]),
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
    deps = [
        "@openvino_linux//:openvino_old_headers",
    ]
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
    name = "openvino",
    srcs = glob([
        "lib/intel64/libopenvino.so",
        "lib/intel64/libopenvino.so.*",
        "lib/intel64/libopenvino_genai.so",
        "lib/intel64/libopenvino_genai.so.*",
    ]),
    data = [
        ":shared_objects",
    ],
    strip_include_prefix = "include/ie",
    visibility = ["//visibility:public"],
    deps = [
        "@openvino_linux//:ngraph",
        "@openvino_linux//:openvino_new_headers",
    ],
)
