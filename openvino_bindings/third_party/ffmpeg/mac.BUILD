licenses(["notice"])  # LGPL

exports_files(["LICENSE"])

cc_library(
    name = "ffmpeg",
    hdrs = glob([
        "include/**/*.h",
    ]),
    srcs = glob([
        "lib/*.dylib",
    ]),
    includes = [
        "lib",
    ],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
