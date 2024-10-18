licenses(["notice"])  # LGPL

exports_files(["LICENSE"])

cc_library(
    name = "ffmpeg",
    hdrs = glob([
        "include/**/*.h",
    ]),
    srcs = [
        "lib/libavdevice.60.dylib",
        "lib/libavformat.60.dylib",
        "lib/libavcodec.60.dylib",
        "lib/libswresample.4.dylib",
        "lib/libavutil.58.dylib",
    ],
    includes = [
        "lib",
    ],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
