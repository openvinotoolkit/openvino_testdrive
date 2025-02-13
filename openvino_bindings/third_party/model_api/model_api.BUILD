load("@rules_foreign_cc//foreign_cc:cmake.bzl", "cmake")

visibility = ["//visibility:public"]

filegroup(
    name = "all_srcs",
    srcs = glob(["model_api/cpp/**"]),
    visibility = ["//visibility:public"],
)

cmake(
    name = "model_api_cmake_mac",
    build_args = [
        "--verbose",
        "--",  # <- Pass remaining options to the native tool.
        # https://github.com/bazelbuild/rules_foreign_cc/issues/329
        # there is no elegant paralell compilation support
        "VERBOSE=1",
        "-j 4",
    ],
    cache_entries = {
        "CMAKE_POSITION_INDEPENDENT_CODE": "ON",
        "OpenVINO_DIR": "/opt/intel/openvino/runtime/cmake",
        "OpenCV_DIR": "/usr/local/lib/cmake/opencv4",
    },
    lib_source = ":all_srcs",
    out_static_libs = ["libmodel_api.a"],
    tags = ["requires-network"],
    visibility = ["//visibility:public"]
)

cmake(
    name = "model_api_cmake_linux",
    build_args = [
        "--verbose",
        "--",  # <- Pass remaining options to the native tool.
        # https://github.com/bazelbuild/rules_foreign_cc/issues/329
        # there is no elegant paralell compilation support
        "VERBOSE=1",
        "-j 4",
    ],
    cache_entries = {
        "CMAKE_POSITION_INDEPENDENT_CODE": "ON",
        "OpenVINO_DIR": "/opt/intel/openvino/runtime/cmake",
    },
    lib_source = ":all_srcs",
    out_static_libs = ["libmodel_api.a"],
    tags = ["requires-network"],
    visibility = ["//visibility:public"]
)

cmake(
    name = "model_api_cmake_windows",
    build_args = [
        "--verbose",
        "--",  # <- Pass remaining options to the native tool.
        # https://github.com/bazelbuild/rules_foreign_cc/issues/329
        # there is no elegant paralell compilation support
        # "VERBOSE=1",
        "-j 4",
    ],
    cache_entries = {
        "CMAKE_POSITION_INDEPENDENT_CODE": "ON",
        "OpenVINO_DIR": "C:/Intel/openvino_2024.6.0/runtime/cmake",
        "OpenCV_DIR": "C:/opencv/build",
    },
    lib_source = ":all_srcs",
    out_static_libs = ["model_api.lib"],
    tags = ["requires-network"],
    visibility = ["//visibility:public"]
)
