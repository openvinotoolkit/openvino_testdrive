licenses(["notice"])  # LGPL

exports_files(["LICENSE"])

cc_library(
    name = "ffmpeg",
    srcs = glob([
        "lib/libavcodec.so.*",
        "lib/libavformat.so.*",
        "lib/libavutil.so.*",
        "lib/libswresample.so.*",
    ]),
    linkopts = glob([
        "-l:libavcodec.so.*",
        "-l:libavformat.so.*",
        "-l:libavutil.so.*",
        "-l:libswresample.so.*",
    ]),
    includes = [
        "include",
    ],
    hdrs = glob(["include/**/*.h"]),
    visibility = ["//visibility:public"],
)
