OPENVINO_VERSION = "2460"

package(
    default_visibility = ["//visibility:public"],
)

filegroup(
    name = "shared_objects",
    srcs = glob([
        "lib/arm64/Release/**/*.so",
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
    srcs = [
        "lib/arm64/Release/libopenvino_tokenizers.dylib",
        "lib/arm64/Release/libcore_tokenizers.dylib",
        "lib/arm64/Release/libopenvino." + OPENVINO_VERSION +".dylib",
        "lib/arm64/Release/libopenvino_c." + OPENVINO_VERSION + ".dylib",
        "lib/arm64/Release/libopenvino_genai." + OPENVINO_VERSION + ".dylib",
        "lib/arm64/Release/libopenvino_ir_frontend." + OPENVINO_VERSION + ".dylib",
        "lib/arm64/Release/libopenvino_onnx_frontend." + OPENVINO_VERSION + ".dylib",
        "lib/arm64/Release/libopenvino_paddle_frontend." + OPENVINO_VERSION + ".dylib",
        "lib/arm64/Release/libopenvino_pytorch_frontend." + OPENVINO_VERSION + ".dylib",
        "lib/arm64/Release/libopenvino_tensorflow_frontend." + OPENVINO_VERSION + ".dylib",
        "lib/arm64/Release/libopenvino_tensorflow_lite_frontend." + OPENVINO_VERSION + ".dylib",
        "3rdparty/tbb/lib/libtbb.12.dylib",
    ],
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
