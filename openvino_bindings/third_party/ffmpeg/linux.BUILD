licenses(["notice"])  # LGPL

exports_files(["LICENSE"])

cc_library(
    name = "ffmpeg",
    linkopts = [
        "-l:libavcodec.so",
        "-l:libavformat.so",
        "-l:libavutil.so",
        "-l:libswresample.so",
    ],
    includes = [
        "include",
    ],
    visibility = ["//visibility:public"],
)
