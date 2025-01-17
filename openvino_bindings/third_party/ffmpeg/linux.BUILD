licenses(["notice"])  # LGPL

exports_files(["LICENSE"])

cc_library(
    name = "ffmpeg",
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
