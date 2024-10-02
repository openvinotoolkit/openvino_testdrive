load("@rules_foreign_cc//foreign_cc:cmake.bzl", "cmake")
visibility = ["//visibility:public"]

filegroup(
    name = "all_srcs",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)

cmake(
    name = "blend2d_linux",
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
    },
    lib_source = ":all_srcs",
    out_shared_libs = ["libblend2d.so"],
    build_data = [
        "@asmjit//:all_srcs"
    ],
    visibility = ["//visibility:public"],
)

cmake(
    name = "blend2d_macos",
    build_args = [
        "--verbose",
        "--",  # <- Pass remaining options to the native tool.
        # https://github.com/bazelbuild/rules_foreign_cc/issues/329
        # there is no elegant paralell compilation support
        "VERBOSE=1",
        "-j 4",
    ],
    lib_source = ":all_srcs",
    out_shared_libs = ["libblend2d.dylib"],
    build_data = [
        "@asmjit//:all_srcs"
    ],
    visibility = ["//visibility:public"],
)

cmake(
    name = "blend2d_windows",
    lib_source = ":all_srcs",
    out_shared_libs = ["blend2d.dll"],
    out_interface_libs = ["blend2d.lib"],
    build_data = [
        "@asmjit//:all_srcs"
    ],
    visibility = ["//visibility:public"],
)
