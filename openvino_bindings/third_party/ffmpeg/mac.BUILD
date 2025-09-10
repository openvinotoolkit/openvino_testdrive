licenses(["notice"])  # LGPL

exports_files(["LICENSE"])

cc_library(
    name = "ffmpeg",
    hdrs = glob([
        "include/**/*.h",
    ]),
    srcs = [
        "lib/libavdevice.61.dylib",
        "lib/libavformat.61.dylib",
        "lib/libavcodec.61.dylib",
        "lib/libswresample.5.dylib",
        "lib/libavutil.59.dylib",
    ],
    includes = [
        "lib",
    ],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
