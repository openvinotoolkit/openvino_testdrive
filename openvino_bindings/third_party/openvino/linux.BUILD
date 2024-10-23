package(
    default_visibility = ["//visibility:public"],
)

OPENVINO_VERSION = "2440"

filegroup(
    name = "shared_objects",
    srcs = [
        "3rdparty/tbb/lib/libtbb.so.12",
        "lib/intel64/libopenvino.so." + OPENVINO_VERSION,
        "lib/intel64/libopenvino_c.so",
        "lib/intel64/libopenvino_genai.so." + OPENVINO_VERSION,
        "lib/intel64/libopenvino_tokenizers.so",
        "lib/intel64/libopenvino_auto_plugin.so",
        "lib/intel64/libopenvino_hetero_plugin.so",
        "lib/intel64/libopenvino_onnx_frontend.so",
        "lib/intel64/libopenvino_paddle_frontend.so",
        "lib/intel64/libopenvino_intel_cpu_plugin.so",
        "lib/intel64/libopenvino_intel_gpu_plugin.so",
        "lib/intel64/libopenvino_intel_npu_plugin.so",
        "lib/intel64/libopenvino_pytorch_frontend.so",
        "lib/intel64/libopenvino_auto_batch_plugin.so",
        "lib/intel64/libopenvino_tensorflow_frontend.so",
        "lib/intel64/libopenvino_tensorflow_lite_frontend.so"
    ]
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
    srcs = [
        ":shared_objects"
    ],
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
