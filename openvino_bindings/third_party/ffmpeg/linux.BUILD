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
    linkopts = [
        "-lavcodec",
        "-lavformat",
        "-lavutil",
        "-lswresample",
    ],
    includes = [
        "include",
    ],
    hdrs = glob(["include/**/*.h"]),
    visibility = ["//visibility:public"],
)
